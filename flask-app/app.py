from flask import Flask
import redis
import os

app = Flask(__name__)

redis_client = redis.Redis(
    host=os.getenv("REDIS_HOST", "redis"),
    port=6379,
    decode_responses=True,
    socket_connect_timeout=5
)

@app.route("/")
def home():
    visits = redis_client.incr("visits") # stores and increments a visit counter in Redis

    return f"Total visits: {visits}\n"

@app.route("/health")
def health():
    return "Flask is running.\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000) # receives http requests on port 5000
