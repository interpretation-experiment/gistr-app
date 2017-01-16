from datetime import datetime
from multiprocessing import Pool
import inspect
import random
import re
import time

from selenium.webdriver.support.ui import Select

from utils import send_keys
import utils


user_password = "abcdef"
pause = 0.5


def register(driver, gistr_url, username):
    # Fill in all inputs
    send_keys(driver.find_element_by_id("InputAutofocus"), username)
    send_keys(driver.find_element_by_id("inputEmail"),
              username + "@browser.test")
    send_keys(driver.find_element_by_id("inputPassword1"), user_password)
    send_keys(driver.find_element_by_id("inputPassword2"), user_password)

    # Submit
    driver.find_element_by_id("inputPassword2").submit()

    # Check we're at the home page, with the right username
    assert driver.find_element_by_css_selector("main h1").text == "Gistr"
    assert driver.find_element_by_css_selector(
        "header .layoutMeta strong").text == username


def read_instructions(driver, gistr_url, path):
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
    # Fill in all inputs
    send_keys(driver.find_element_by_id("inputAge"), "20")
    driver.find_element_by_css_selector("main input[value=other]").click()
    education = Select(driver.find_element_by_id("inputEducationLevel"))
    education.select_by_visible_text("Primary")
    send_keys(driver.find_element_by_id("inputEducationFreetext"),
              "Some education")
    job = Select(driver.find_element_by_id("inputJobType"))
    job.select_by_visible_text("Other")
    send_keys(driver.find_element_by_id("inputJobFreetext"), "Some job")

    # Submit, twice (for confirmation), waiting for the buttons to appear each
    # time
    driver.find_element_by_css_selector("main input[type=submit]").click()
    time.sleep(pause)
    driver.find_element_by_css_selector("main input[type=submit]").click()

    # Check we're at the profile page, with the questionnaire completed
    assert driver.find_element_by_css_selector("header h1").text == "Profile"
    status = driver.find_element_by_css_selector('main .layoutWell h4').text
    assert ('Questionnaire' in status) and ('Done' in status)


def run_trial(config, driver, username):
    driver.find_element_by_id('CtrlNext').click()

    text = driver.find_element_by_css_selector('main blockquote').text
    read_time = config.read_factor * len(re.split(' +', text))
    time.sleep(read_time)

    # The task wait time is absorbed in the driver's implicit wait
    send_keys(driver.find_element_by_id('InputAutofocus'),
              'some text ' * random.randint(5, 8))
    driver.find_element_by_id('CtrlNext').click()

    # Wait until the sentence is saved to return. Or raise an exception.
    for i in range(30):
        time.sleep(1)
        title = driver.find_element_by_css_selector('main h3').text
        if ("saved" in title) or ("finished" in title):
            return

    raise Exception("Never reached 'sentence saved' state")


def _full_run(config, gistr_url, username, driver):
    # Do all the pre-exp stuff
    driver.get(gistr_url + "/register")
    register(driver, gistr_url, username)
    read_instructions(driver, gistr_url, '/')
    driver.find_element_by_css_selector('header .layoutAvatar').click()
    driver.find_element_by_css_selector('main .layoutWell h4 button').click()
    fill_questionnaire(driver, gistr_url)
    driver.find_element_by_css_selector('main .layoutInfoBox button').click()
    read_instructions(driver, gistr_url, '/experiment')

    # Run through the trials
    n_trials = 0
    title = driver.find_element_by_css_selector('header h1').text
    while 'Done' not in title:
        run_trial(config, driver, username)
        n_trials += 1
        title = driver.find_element_by_css_selector('header h1').text

    # And make sure we saw the right amount of trials
    assert n_trials == config.training_work + config.experiment_work


def full_run(config, gistr_url, username, driver=None):
    if driver is None:
        with utils.driver() as driver:
            _full_run(config, gistr_url, username, driver)
    else:
        _full_run(config, gistr_url, username, driver)


def test_full_run(live_server, config, sentences, driver, gistr_url):
    full_run(config, gistr_url, 'test_guy', driver)


def wait_then_full_run(wait_config_gistrurl_username):
    (wait, config, gistr_url, username) = wait_config_gistrurl_username
    time.sleep(wait)
    full_run(config, gistr_url, username)


def test_concurrent_full_runs(live_server, concurrent_config, sentences,
                              gistr_url):
    n_users = (concurrent_config.target_branch_count
               * concurrent_config.target_branch_depth)
    args = [(random.uniform(0, 20 * n_users),
             concurrent_config,
             gistr_url,
             't{}'.format(i))
            for i in range(n_users)]

    with Pool(n_users) as pool:
        pool.map(wait_then_full_run, args)

    dump_filename = ('{name} W={work} C={branch_count} '
                     'D={branch_depth} {time}.sql').format(
        name=inspect.currentframe().f_code.co_name, time=datetime.now(),
        work=concurrent_config.experiment_work,
        branch_count=concurrent_config.target_branch_count,
        branch_depth=concurrent_config.target_branch_depth)
    utils.dump_sqlite_memory(dump_filename)
