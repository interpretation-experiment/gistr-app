import time

from selenium.webdriver.support.ui import Select


user_password = "abcdef"


def test_about_page(driver, gistr_url):
    driver.get(gistr_url)
    driver.find_element_by_css_selector('a[data-tooltip="About Gistr"]')\
        .click()
    assert driver.find_element_by_css_selector("header h1").text == "About"
    assert "game" in driver.find_element_by_css_selector("main h1").text
    assert driver.current_url == gistr_url + "/about"


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

    # Then skip the intro on the home page
    skip = driver.find_element_by_css_selector(
        ".elm-intro-tooltipActive button")
    time.sleep(1)
    assert skip.text == "Skip"
    skip.click()
    time.sleep(1)

    # Check we're at the home page
    assert driver.find_element_by_css_selector("main h1").text == "Gistr"


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

    # Submit, twice (for confirmation)
    driver.find_element_by_css_selector("main input[type=submit]").click()
    time.sleep(1)
    driver.find_element_by_css_selector("main input[type=submit]").click()
    time.sleep(1)

    # Check we're at the profile page
    assert driver.find_element_by_css_selector("header h1").text == "Profile"


def test_experiment(live_server, driver, gistr_url):
    register(driver, gistr_url, 't12')
    fill_questionnaire(driver, gistr_url)
    # TODO: use sentences fixture
    # TODO: go through exp


# TODO: make a test_concurrent_experiment() using test_experiment with several
# drivers, then testing for tree shapes
