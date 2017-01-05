import pytest

from gists.models import (Profile, Sentence, Tree, DEFAULT_LANGUAGE,
                          GistsConfiguration)

import utils


@pytest.fixture
def gistr_url():
    return "http://localhost:3000"


@pytest.fixture
def driver():
    with utils.driver() as driver:
        yield driver


@pytest.fixture
@pytest.mark.django_db
def config():
    # FIXME: This will need transactional_db if the fixture is reused
    config = GistsConfiguration.get_solo()
    config.training_work = 3
    config.experiment_work = 10
    config.save()
    return config


@pytest.fixture
def sentences(config, admin_user):
    # FIXME: This will need transactional_db if the fixture is reused
    # Create a few training and experiment sentences
    admin_profile = Profile(user=admin_user, mothertongue=DEFAULT_LANGUAGE)
    admin_profile.save()
    for i in range(config.training_work):
        t = Tree.objects.create()
        s = Sentence(profile=admin_profile, tree=t, tree_as_root=t,
                     read_time_proportion=0, read_time_allotted=0,
                     write_time_proportion=0, write_time_allotted=0,
                     language=DEFAULT_LANGUAGE, bucket='training',
                     text='training ' + str(i))
        s.save()
    for i in range(config.experiment_work):
        t = Tree.objects.create()
        s = Sentence(profile=admin_profile, tree=t, tree_as_root=t,
                     read_time_proportion=0, read_time_allotted=0,
                     write_time_proportion=0, write_time_allotted=0,
                     language=DEFAULT_LANGUAGE, bucket='experiment',
                     text='experiment ' + str(i))
        s.save()
