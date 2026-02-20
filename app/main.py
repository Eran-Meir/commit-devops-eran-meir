from flask import Flask

app = Flask(__name__)

@app.route('/get')
@app.route('/')
def hello():
    return "Hello world"

if __name__ == '__main__':
    # Listen on 8080 to avoid root port permission issues in the container
    app.run(host='0.0.0.0', port=8080)