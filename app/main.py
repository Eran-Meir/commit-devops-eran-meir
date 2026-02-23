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
    """Deliberately shreds the CPU for 30 seconds to guarantee an HPA trigger."""
    timeout = time.time() + 30
    while time.time() < timeout:
        # Absolutely massive floating-point array computation
        _ = [x**3.5 for x in range(50000)]
    return "Extreme CPU spike complete! Check your HPA metrics.", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)