import re, random
with open('lib/data/food_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

def repl_restaurant_ids(match):
    # Pick 5 random IDs between 100 and 209
    ids = random.sample(range(100, 210), 5)
    id_strs = [f"'{i}'" for i in ids]
    return 'itemIds: [' + ', '.join(id_strs) + '],'

content = re.sub(r'itemIds:\s*\[.*?\],', repl_restaurant_ids, content)

with open('lib/data/food_data.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated restaurant item IDs')
