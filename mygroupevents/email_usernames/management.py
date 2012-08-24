from django.db.models.signals import post_syncdb

message = """
    'django-email-accounts' has detected that you just installed Django's authentication system (django.auth). 
         
    For your convenience, django-email-accounts can alter the user table's username field to allow 75 characters instead
    of the default 35 chars. Unless you do this, emails that are longer than 30 characters will be cut off, and this 
    app will probably not work!
    
    NOTE: this will only work if the SQL user account you have created for django has the privileges
    to run ALTER statements.
    
    Do you want django-email-accounts to try to alter the auth_user.username column to allow 75 characters? 
    (y/N): """

def query_fix_usertable(sender, app, created_models, verbosity, interactive, **kwargs):
    model_names = [m.__name__ for m in created_models]
    if not interactive or app.__name__ != 'django.contrib.auth.models' or "User" not in model_names:
        return
    
    answer = raw_input(message)
    while not answer.lower() in ('y', 'n', 'yes', 'no'):
        raw_input("You need to either decide yes ('y') or no ('n'). Default is no. (y/N): ")
        
    from django.db import connection
    cursor = connection.cursor()
    cursor.execute("ALTER TABLE auth_user MODIFY COLUMN username varchar(75) NOT NULL")
    
post_syncdb.connect(query_fix_usertable)