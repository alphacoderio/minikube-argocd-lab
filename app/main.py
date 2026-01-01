from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/")
def root():
    return {"message": "Hello from Minikube", "Version": "2"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
