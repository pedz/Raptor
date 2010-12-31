# -*- coding: utf-8 -*-

# Some history is needed.  Currently, Raptor always does synchronous
# requests to Retain.  As a queue is fetched, either Retain or
# Combined models are created for each call and PMR and when fields in
# those models are touched, more calls to Retain are fired.  This can
# go on for some while.
#
# At this point, Raptor needs the ability to do some requests
# asynchronously.  This file creates a class that will contain the
# retain user to use for the request along with the request to make.
# When the request is executed, the Logon params will be set and the
# request executed.  I don't know yet what I'm going to do about the
# errors aside from log them.
#
# The beanstalkd, async_observer, and beanstalk-client code (gems) is
# used to provide the asynchronous ability.  The way that works is
# AsyncObserver::Extensions will be mixed into this class.  The
# async_send method is called on the object which serializes the
# object along with the method to call (what is termed the
# "selector"), sent to the "worker", which reconstructs the object and
# executes the selector.

module Retain
  class Async
  end
end
