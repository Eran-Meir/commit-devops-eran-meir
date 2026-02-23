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
    """Deliberately shreds the CPU for 20 seconds to guarantee an HPA trigger."""
    timeout = time.time() + 20  # Increased to 20 seconds per request
    while time.time() < timeout:
        # 10x heavier: Massive floating-point array computation
        _ = [x**2.5 for x in range(15000)]
    return "Extreme CPU spike complete! Check your HPA metrics.", 200

if __name__ == '__main__':
    # Listen on 8080 to avoid root port permission issues in the container
    app.run(host='0.0.0.0', port=8080)