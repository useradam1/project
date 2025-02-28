import os
ASSETS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Assets')
if not os.path.exists(ASSETS_PATH):
	os.makedirs(ASSETS_PATH)