#!/usr/bin/env python

from setuptools import setup, find_packages

VERSION = "0.1.0"


setup(
    name="naming",
    version=VERSION,
    description="Naming functions to avoid duplications in AWS Lambdas",
    author="Aldo 'xoen' Giambelluca",
    author_email="aldo.giambelluca@digital.justice.gov.uk",
    url="https://github.com/ministryofjustice/analytics-platform-ops",
    packages=find_packages(),
)
