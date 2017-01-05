def test_about_page(driver, gistr_url):
    driver.get(gistr_url)
    driver.find_element_by_css_selector('a[data-tooltip="About Gistr"]')\
        .click()
    assert driver.find_element_by_css_selector("header h1").text == "About"
    assert "game" in driver.find_element_by_css_selector("main h1").text
    assert driver.current_url == gistr_url + "/about"
