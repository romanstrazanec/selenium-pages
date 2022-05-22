require 'io/console'

class Duolingo < Page
  I_ALREADY_HAVE_ACCOUNT_BUTTON = '/html/body/div[1]/div/div/span[1]/div/div[1]/div[2]/div[2]/button'.freeze
  USERNAME = '/html/body/div[2]/div[4]/div/div/form/div[1]/div[1]/div[1]/label/div/input'.freeze
  PASSWORD = '/html/body/div[2]/div[4]/div/div/form/div[1]/div[1]/div[2]/label/div[1]/input'.freeze

  @@dict = {}
  attr_accessor :logged_in

  def self.dict = @@dict
  def dict = @@dict

  def initialize(*, driver: nil, username: nil, **)
    super
    @driver.get 'https://duolingo.com'

    login username: username if username
  end

  def login(*, username:, **)
    find_element(xpath: I_ALREADY_HAVE_ACCOUNT_BUTTON).click

    find_element(xpath: USERNAME).send_keys username

    password = STDIN.getpass 'Password: '
    find_element(xpath: PASSWORD).send_keys password, :return

    @logged_in = true
  end

  def open_skill(*, name:, language: 'de', **)
    url = "https://duolingo.com/skill/#{language.downcase}/#{name.downcase.capitalize}"
    logger.info "Opening skill at '#{url}'"
    @driver.get url
  end

  def start
    find_element(text: 'START', timeout: 2).click
  rescue
    find_element(attr: 'data-test', value: 'start-button', timeout: 2).click
  end

  def run(*, skill_name: nil, username: nil, password: nil, **)
    login username: username, password: password if username && password && !logged_in

    if logged_in
      if skill_name
        open_skill name: skill_name

        run_skill
      end
    end
  end

  def run_skill(*, name: nil, **)
    open_skill name: name if name

    begin
      step while true
    rescue => e
      logger.warn e
      start rescue nil

      if !@use_keyboard && (use_keyboard = find_element(text: 'Use keyboard', timeout: 1))
        logger.info 'Using keyboard.'
        use_keyboard.click
        @use_keyboard = true
      elsif !@cannot_listen_now && (cannot_listen_now = find_element(text: "Can't listen now", timeout: 1))
        logger.info 'Cannot listen now.'
        cannot_listen_now.click
        @cannot_listen_now = true
      end

      run_skill
    end
  end

  def step
    logger.info 'Step.'
    find_element(text: 'Continue', timeout: 3)&.click

    hint = find_elements(attr: 'data-test', value: 'hint-token', timeout: 3)
    logger.warn "AHOOJ #{hint.present?}"
    return if hint.blank?

    logger.warn "CAAAU"

    logger.info "1 #{hint}"
    logger.info "2 #{hint.filter_map { |el| el.text.clean.presence }}"
    logger.info "3 #{hint.filter_map { |el| el.text.clean.presence }.join(' ')}"
    logger.info "4 #{hint.filter_map { |el| el.text.clean.presence }.join(' ').strip.gsub(/\s\s+/, ' ')}"

    hint = hint.filter_map { |el| el.text.clean.presence }.join(' ').strip.gsub(/\s\s+/, ' ')
    logger.warn "COOOL"

    return if hint.blank?

    translated = translate hint

    if translated
      if (incorrect = find_element(attr: 'data-test', value: 'blame blame-incorrect', timeout: 3))
        logger.warn "VIIII"
        translated = incorrect.child(xpath: '//h2/following-sibling::div').text.clean.strip
        logger.warn "VIIII #{translated}"
      end

      @@dict[hint] = translated
      @@dict[translated] = hint
    end
  end

  def translate(text)
    logger.info "Translating '#{text}'..."
    input = find_element attr: 'data-test', value: 'challenge-translate-input', timeout: 1
    return unless input

    translated = @@dict[text] || begin
      if input.attribute('placeholder').include? 'English'
        tl = 'en'
        sl = 'de'
      else
        tl = 'de'
        sl = 'en'
      end

      GoogleTranslate.new.translate text, tl: tl, sl: sl
    end

    logger.info "Translation complete '#{translated}'"
    input.send_keys translated, :return
    translated
  end

  def quit = @driver.quit
end
