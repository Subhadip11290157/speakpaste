import sys
import re

text = sys.stdin.read()

# Normalize whitespace
text = re.sub(r'\s+', ' ', text)

# Remove common filler words (standalone only)
fillers = [
    r'\buh\b',
    r'\bum\b',
    r'\byou know\b'
]

for f in fillers:
    text = re.sub(f, '', text, flags=re.IGNORECASE)

# Fix spacing before punctuation
text = re.sub(r'\s+([,.!?])', r'\1', text)

# Trim
text = text.strip()

# Capitalize first letter (safe)
if text:
    text = text[0].upper() + text[1:]

print(text)

