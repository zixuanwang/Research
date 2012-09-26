 # import the logging library
import logging

# Get an instance of a logger
logger = logging.getLogger('myevents.debug')

def my_log(request, arg1, arg):
    if bad_mojo:
        # Log an error message
        logger.error('Something went wrong!')