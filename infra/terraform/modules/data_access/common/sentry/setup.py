#!/usr/bin/env python

from setuptools import setup, find_packages

VERSION = "0.1.0"


setup(
    name="sentry",
    version=VERSION,
    description="Annotation to send exceptions to sentry",
    author="Aldo 'xoen' Giambelluca",
    author_email="aldo.giambelluca@digital.justice.gov.uk",
    url="https://github.com/ministryofjustice/analytics-platform-ops",
    packages=find_packages(),
)
