import time

from selenium.webdriver.support.ui import Select


user_password = "abcdef"
pause = 0.5


def register(driver, gistr_url, username):
    # Navigate
    driver.get(gistr_url + "/register")

    # Fill in all inputs
    driver.find_element_by_id("InputAutofocus").send_keys(username)
    driver.find_element_by_id("inputEmail").send_keys(
        username + "@browser.test")
    driver.find_element_by_id("inputPassword1").send_keys(user_password)
    driver.find_element_by_id("inputPassword2").send_keys(user_password)

    # Submit
    driver.find_element_by_id("inputPassword2").submit()

    # Check we're at the home page, with the right username
    assert driver.find_element_by_css_selector("main h1").text == "Gistr"
    assert driver.find_element_by_css_selector(
        "header .layoutMeta strong").text == username


def read_instructions(driver, gistr_url, path):
    # Navigate
    driver.get(gistr_url + path)

    # Wait for instructions to appear
    time.sleep(pause)

    # And loop through them
    controls = driver.find_elements_by_css_selector(
        ".elm-intro-tooltipActive button")
    finish, next = controls[0], controls[2]
    while finish.text == "Skip":
        next.click()
        time.sleep(pause)
        controls = driver.find_elements_by_css_selector(
            ".elm-intro-tooltipActive button")
        finish, next = controls[0], controls[2]

    assert finish.text == "Done"
    finish.click()
    time.sleep(pause)


def fill_questionnaire(driver, gistr_url):
    # Navigate
    driver.get(gistr_url + "/profile/questionnaire")

    # Fill in all inputs
    driver.find_element_by_id("inputAge").send_keys("20")
    driver.find_element_by_css_selector("main input[value=other]").click()
    education = Select(driver.find_element_by_id("inputEducationLevel"))
    education.select_by_visible_text("Primary")
    driver.find_element_by_id("inputEducationFreetext")\
        .send_keys("Some education")
    job = Select(driver.find_element_by_id("inputJobType"))
    job.select_by_visible_text("Other")
    driver.find_element_by_id("inputJobFreetext").send_keys("Some job")

    # Submit, twice (for confirmation), waiting for the buttons to appear each
    # time
    driver.find_element_by_css_selector("main input[type=submit]").click()
    time.sleep(pause)
    driver.find_element_by_css_selector("main input[type=submit]").click()
    time.sleep(pause)

    # Check we're at the profile page, with the questionnaire completed
    assert driver.find_element_by_css_selector("header h1").text == "Profile"
    status = driver.find_element_by_css_selector('main .layoutWell h4').text
    assert ('Questionnaire' in status) and ('Done' in status)


def run_trial(config, driver, username):
    driver.find_element_by_id('CtrlNext').click()
    time.sleep(pause)

    text = driver.find_element_by_css_selector('main blockquote').text
    read_time = config.read_factor * len(text.split(' '))
    time.sleep(read_time)

    # The task wait time is absorbed in the driver's implicit wait
    driver.find_element_by_id(
        'InputAutofocus').send_keys((username + ' ') * 10)
    driver.find_element_by_id('CtrlNext').click()
    time.sleep(pause)


def test_full_run(live_server, config, sentences, driver, gistr_url):
    username = 't1'

    # Do all the pre-exp stuff
    register(driver, gistr_url, username)
    read_instructions(driver, gistr_url, '/')
    fill_questionnaire(driver, gistr_url)
    read_instructions(driver, gistr_url, '/experiment')

    # Run through the trials
    trials = 0
    title = driver.find_element_by_css_selector('header h1').text
    while 'Done' not in title:
        run_trial(config, driver, username)
        trials += 1
        title = driver.find_element_by_css_selector('header h1').text

    # And make sure we saw the right amount of trials
    assert trials == config.training_work + config.experiment_work


# TODO: make a test_concurrent_experiment() using test_experiment with several
# drivers, then testing for tree shapes
