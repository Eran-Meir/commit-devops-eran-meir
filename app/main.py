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
    """Deliberately spikes the CPU for 15 seconds to trigger the HPA."""
    timeout = time.time() + 15  # Run for 15 seconds
    while time.time() < timeout:
        # Heavy mathematical computation to burn CPU cycles
        math.factorial(1000)
    return "CPU spike complete! Check your HPA metrics.", 200

if __name__ == '__main__':
    # Listen on 8080 to avoid root port permission issues in the container
    app.run(host='0.0.0.0', port=8080)