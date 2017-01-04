from contextlib import contextmanager

from selenium import webdriver


@contextmanager
def driver():
    driver = webdriver.Firefox()
    driver.implicitly_wait(10)
    try:
        yield driver
    finally:
        driver.quit()
