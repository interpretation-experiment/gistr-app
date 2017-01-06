from contextlib import contextmanager
import os
import time

from selenium import webdriver


def dump_sqlite_memory(filename):
    folder = os.path.join(os.path.dirname(__file__), 'sqldumps')
    try:
        os.mkdir(folder)
    except FileExistsError:
        pass

    from django.db import connection
    con = connection.get_new_connection(connection.get_connection_params())

    with open(os.path.join(folder, filename), 'w') as f:
        for line in con.iterdump():
            f.write('%s\n' % line)

    con.close()


def send_keys(el, keys):
    for k in keys:
        el.send_keys(k)
        time.sleep(0.1)


@contextmanager
def driver():
    driver = webdriver.Chrome()
    driver.implicitly_wait(10)
    try:
        yield driver
    finally:
        driver.quit()
