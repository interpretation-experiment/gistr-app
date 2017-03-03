from contextlib import contextmanager
import os
import time

from django.core.management.commands import dumpdata

from selenium import webdriver


def dump_db(filename):
    folder = os.path.join(os.path.dirname(__file__), 'dbdumps')
    try:
        os.mkdir(folder)
    except FileExistsError:
        pass

    dumper = dumpdata.Command()
    dumper.run_from_argv(
        ['', '', '--output', os.path.join(folder, filename),
         'gists', 'solo', 'auth'])


def send_keys(el, keys):
    for k in keys:
        el.send_keys(k)
        time.sleep(0.1)


@contextmanager
def driver():
    driver = webdriver.Chrome()
    # desired_cap = {
    #     'os': 'Windows',
    #     'os_version': '10',
    #     'browser': 'Firefox',
    #     'browser_version': '50',
    #     'browserstack.local': True
    # }
    # driver = webdriver.Remote(command_executor=os.environ['REMOTE_EXECUTOR'],
    #                           desired_capabilities=desired_cap)
    driver.implicitly_wait(60)
    try:
        yield driver
    finally:
        driver.quit()
