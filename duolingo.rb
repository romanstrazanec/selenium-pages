require 'io/console'

class Duolingo < Page
  I_ALREADY_HAVE_ACCOUNT_BUTTON = '/html/body/div[1]/div/div/span[1]/div/div[1]/div[2]/div[2]/button'.freeze
  USERNAME = '/html/body/div[2]/div[4]/div/div/form/div[1]/div[1]/div[1]/label/div/input'.freeze
  PASSWORD = '/html/body/div[2]/div[4]/div/div/form/div[1]/div[1]/div[2]/label/div[1]/input'.freeze

  @@dict = {}
  attr_accessor :logged_in

  def self.dict = @@dict
  def dict = @@dict

  def initialize(*, driver: nil, **)
    super
    @driver.get 'https://duolingo.com'
  end

  def login(*, username:, **)
    find_element(xpath: I_ALREADY_HAVE_ACCOUNT_BUTTON).click

    find_element(xpath: USERNAME).send_keys username

    password = STDIN.getpass 'Password: '
    find_element(xpath: PASSWORD).send_keys password, :return

    @logged_in = true
  end

  def open_skill(name, *, **)
    find_element(text: name, timeout: 4).parent.click

    sleep 1
    find_element(text: 'Legendary +40 XP', timeout: 1)&.click
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
        open_skill skill_name

        run_skill
      end
    end
  end

  def run_skill
    start

    find_element(attr: 'role', value: 'progressbar', timeout: nil)

    begin
      step while true
    rescue
      find_element(text: 'Continue', timeout: 7)&.click
      run_skill
    end
  end

  def step
    find_element(text: 'Continue', timeout: 1)&.click

    if !@use_keyboard && (use_keyboard = find_element(text: 'Use keyboard', timeout: 1))
      use_keyboard.click
      @use_keyboard = true
    elsif !@cannot_listen_now && (cannot_listen_now = find_element(text: "Can't listen now", timeout: 1))
      cannot_listen_now.click
      @cannot_listen_now = true
    else
      hint = find_elements(attr: 'data-test', value: 'hint-token', timeout: 1)
               .filter_map { |el| el.text.clean.presence }.join(' ').strip.gsub(/\s\s+/, ' ')

      translated = translate hint

      if translated
        if (incorrect = find_element(attr: 'data-test', value: 'blame blame-incorrect', timeout: 1))
          translated = incorrect.child(xpath: '//h2/following-sibling::div').text.clean.strip
        end

        @@dict[hint] = translated
        @@dict[translated] = hint
      end
    end
  end

  def translate(text)
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

    input.send_keys translated, :return
    translated
  end
end
