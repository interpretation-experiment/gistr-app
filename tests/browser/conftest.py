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
def config():
    config = GistsConfiguration.get_solo()
    config.training_work = 2
    config.experiment_work = 3
    config.save()
    return config


@pytest.fixture
def concurrent_config(config):
    config.experiment_work = 10
    config.target_branch_count = 3
    config.target_branch_depth = 5
    config.save()
    return config


@pytest.fixture
def sentences(config, admin_user):
    base_sentence = 'root {} with more text to reach the limit'

    # Create a few training and experiment sentences
    admin_profile = Profile(user=admin_user, mothertongue=DEFAULT_LANGUAGE)
    admin_profile.save()
    for i in range(config.training_work):
        t = Tree.objects.create()
        s = Sentence(profile=admin_profile, tree=t, tree_as_root=t,
                     read_time_proportion=0, read_time_allotted=0,
                     write_time_proportion=0, write_time_allotted=0,
                     language=DEFAULT_LANGUAGE, bucket='training',
                     text='training ' + base_sentence.format(i))
        s.save()
    for i in range(config.experiment_work):
        t = Tree.objects.create()
        s = Sentence(profile=admin_profile, tree=t, tree_as_root=t,
                     read_time_proportion=0, read_time_allotted=0,
                     write_time_proportion=0, write_time_allotted=0,
                     language=DEFAULT_LANGUAGE, bucket='experiment',
                     text='experiment ' + base_sentence.format(i))
        s.save()
