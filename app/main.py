import time
import math
from flask import Flask

app = Flask(__name__)

@app.route('/get')
@app.route('/')
def hello():
    return "Hello world"

@app.route('/hpa')
def generate_load():
    """Generates a controlled CPU spike so 1 request doesn't instantly max the HPA."""
    timeout = time.time() + 30
    while time.time() < timeout:
        # Lighter math computation
        _ = [x**2.0 for x in range(10000)]
        # CRUCIAL: Sleep for 50 milliseconds to yield the CPU and prevent pegging the limit
        time.sleep(0.05)
    return "Throttled CPU spike complete! Check your HPA metrics.", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)