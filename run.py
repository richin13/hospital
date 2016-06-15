from application import app

# Public because we're not deploying this thing
app.secret_key = b'\x06\xa1@3\xa9%\xb1Q\x16>\xd6\xa4\x87\xa5\xde""\xb3\x95\x03s*\x85\xfd'

if __name__ == '__main__':
    app.run(debug=True)
