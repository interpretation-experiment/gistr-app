import pytest

import utils


@pytest.fixture
def driver():
    with utils.driver() as driver:
        yield driver


@pytest.fixture
def gistr_url():
    return "http://localhost:3000"


@pytest.fixture
def sentences():
    # TODO: use the admin fixture
    # TODO: create training + exp sentences
    # TODO: set meta (shaping) settings
    pass
