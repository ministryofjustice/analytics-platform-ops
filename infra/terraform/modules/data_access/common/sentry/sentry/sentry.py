'''
Environment variables:
 - ENV, e.g. "dev", "alpha", etc...
 - SENTRY_DSN, Sentry DSN
'''

import os

from raven import Client as Sentry
from raven.transport.http import HTTPTransport as SentryHTTPTransport


def catch_exceptions(fn):
    def wrapped(*args, **kwargs):
        try:
            fn(*args, **kwargs)
        except Exception:
            client = Sentry(
                os.environ["SENTRY_DSN"],
                transport=SentryHTTPTransport,
                environment=os.environ["ENV"],
            )
            client.captureException()
            raise

    return wrapped
