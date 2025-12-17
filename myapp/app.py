from flask import Flask
import os

app = Flask(__name__)

# Get environment variable defined in Kubernetes ConfigMap/Secret
GREETING = os.environ.get('GREETING_MESSAGE', 'Welcome to the Secure Pipeline!')
APP_VERSION = os.environ.get('APP_VERSION', 'v1.0')

@app.route('/')
def hello_world():
    # Simple output showing the app version and the environment-set greeting
    return f'<h1>App Status: Running - Version {APP_VERSION}</h1><p>{GREETING}</p>'

if __name__ == '__main__':
    # Listen on all interfaces (0.0.0.0)
    app.run(debug=True, host='0.0.0.0', port=5000)
