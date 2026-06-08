import random
import re

categories_data = {
    'Breakfast': [
        ('Pancakes', 'Fluffy buttermilk pancakes with maple syrup'),
        ('Waffles', 'Crispy Belgian waffles with berries'),
        ('Omelette', 'Three egg omelette with cheese and herbs'),
        ('Masala Dosa', 'Crispy crepe served with sambar and chutney'),
        ('Aloo Paratha', 'Stuffed flatbread with spiced potatoes'),
        ('Idli Vada', 'Steamed rice cakes and lentil doughnuts'),
        ('French Toast', 'Brioche bread soaked in egg and cinnamon'),
        ('Avocado Toast', 'Smashed avocado on sourdough bread'),
        ('Poha', 'Flattened rice cooked with onions and peanuts'),
        ('Upma', 'Savory semolina porridge with vegetables')
    ],
    'Lunch': [
        ('South Indian Thali', 'Rice, sambar, rasam, curries and papad'),
        ('Grilled Chicken Bowl', 'Quinoa, grilled chicken and veggies'),
        ('Paneer Wrap', 'Spiced cottage cheese wrapped in flatbread'),
        ('Caesar Salad', 'Romaine lettuce, croutons, and parmesan'),
        ('Veg Sandwich', 'Layered bread with cheese and fresh veggies'),
        ('Pasta Marinara', 'Penne pasta in rich tomato sauce'),
        ('Burrito Bowl', 'Mexican rice, beans, salsa, and guacamole'),
        ('Fish Curry', 'Tangy and spicy fish cooked in coconut milk'),
        ('Mutton Biryani', 'Slow cooked aromatic rice with tender meat'),
        ('Chole Bhature', 'Spicy chickpeas with fried bread')
    ],
    'Dinner': [
        ('Butter Chicken', 'Tender chicken in rich tomato gravy'),
        ('Paneer Tikka Masala', 'Grilled paneer in spiced curry'),
        ('Dal Makhani', 'Slow cooked black lentils with cream'),
        ('Rogan Josh', 'Traditional Kashmiri lamb curry'),
        ('Pad Thai', 'Stir-fried rice noodles with peanuts'),
        ('Lasagna', 'Layers of pasta, meat sauce, and cheese'),
        ('Steak', 'Grilled beef steak with mashed potatoes'),
        ('Ramen', 'Japanese noodle soup with pork and egg'),
        ('Salmon Asparagus', 'Baked salmon with roasted asparagus'),
        ('Veg Stir Fry', 'Mixed vegetables tossed in soy sauce')
    ],
    'Dessert': [
        ('Chocolate Brownie', 'Warm fudge brownie with walnuts'),
        ('Vanilla Ice Cream', 'Classic vanilla bean ice cream'),
        ('Cheesecake', 'New York style cheesecake with strawberry'),
        ('Tiramisu', 'Coffee-flavored Italian dessert'),
        ('Gulab Jamun', 'Deep fried dough balls in sugar syrup'),
        ('Rasmalai', 'Soft paneer discs in sweetened milk'),
        ('Jalebi', 'Crispy swirls soaked in saffron syrup'),
        ('Apple Pie', 'Traditional baked apple pie with crust'),
        ('Macarons', 'Assorted colorful French almond cookies'),
        ('Chocolate Lava Cake', 'Warm cake with a gooey chocolate center')
    ],
    'Drinks': [
        ('Cold Coffee', 'Blended coffee with milk and ice cream'),
        ('Mango Lassi', 'Sweet yogurt drink with mango pulp'),
        ('Fresh Lemonade', 'Refreshing lemon water with mint'),
        ('Virgin Mojito', 'Mint, lime, and soda water'),
        ('Peach Iced Tea', 'Chilled tea with peach syrup'),
        ('Latte', 'Espresso with steamed milk'),
        ('Oreo Milkshake', 'Thick shake blended with Oreo cookies'),
        ('Mixed Berry Smoothie', 'Blended strawberries, blueberries, and yogurt'),
        ('Fresh Orange Juice', '100% natural squeezed orange juice'),
        ('Green Tea', 'Warm brewed green tea leaves')
    ],
    'Pizza': [
        ('Margherita Pizza', 'Classic tomato sauce, mozzarella, and basil'),
        ('Pepperoni Pizza', 'Loaded with spicy pepperoni slices'),
        ('Veggie Supreme', 'Bell peppers, onions, olives, and mushrooms'),
        ('Paneer Tikka Pizza', 'Fusion pizza with spicy paneer chunks'),
        ('BBQ Chicken Pizza', 'Grilled chicken, BBQ sauce, and onions'),
        ('Hawaiian Pizza', 'Pineapple and ham on a cheese base'),
        ('Four Cheese', 'Mozzarella, cheddar, parmesan, and gouda'),
        ('Mushroom Delight', 'Truffle oil and assorted mushrooms'),
        ('Chicken Dominator', 'Spicy chicken tikka and sausages'),
        ('Farmhouse Pizza', 'Fresh farm vegetables and extra cheese')
    ],
    'Burgers': [
        ('Classic Cheeseburger', 'Beef patty, American cheese, and pickles'),
        ('Veggie Burger', 'Plant-based patty with fresh lettuce'),
        ('Crispy Chicken Burger', 'Fried chicken breast and mayo'),
        ('Mushroom Swiss Burger', 'Sautéed mushrooms and Swiss cheese'),
        ('Spicy Paneer Burger', 'Crispy paneer patty with spicy sauce'),
        ('Double Beef Burger', 'Two beef patties and double cheese'),
        ('Bacon Burger', 'Crispy bacon strips and cheddar'),
        ('Fish Burger', 'Crumb fried fish fillet with tartar sauce'),
        ('BBQ Burger', 'Beef patty drenched in smoky BBQ sauce'),
        ('Black Bean Burger', 'Spiced black bean patty with avocado')
    ],
    'Sushi': [
        ('California Roll', 'Crab, avocado, and cucumber'),
        ('Spicy Tuna Roll', 'Minced tuna with spicy mayo'),
        ('Dragon Roll', 'Eel, cucumber, topped with avocado'),
        ('Salmon Nigiri', 'Fresh slice of salmon over pressed rice'),
        ('Tuna Sashimi', 'Thick slices of raw premium tuna'),
        ('Veg Sushi', 'Cucumber, avocado, and pickled radish'),
        ('Rainbow Roll', 'Assorted fish layered over a California roll'),
        ('Shrimp Tempura Roll', 'Crispy fried shrimp with rice'),
        ('Spider Roll', 'Soft shell crab with spicy sauce'),
        ('Eel Roll', 'Grilled freshwater eel with unagi sauce')
    ],
    'Indian': [
        ('Palak Paneer', 'Spinach gravy with cottage cheese'),
        ('Malai Kofta', 'Potato and cheese dumplings in rich gravy'),
        ('Chicken Biryani', 'Aromatic rice with spiced chicken'),
        ('Mutton Curry', 'Spicy and tender mutton stew'),
        ('Aloo Gobi', 'Stir fried potatoes and cauliflower'),
        ('Bhindi Masala', 'Spiced okra cooked with onions'),
        ('Pav Bhaji', 'Spiced mashed veg served with buttered bread'),
        ('Samosa', 'Crispy pastry stuffed with spiced potatoes'),
        ('Garlic Naan', 'Tandoor baked bread with garlic and butter'),
        ('Fish Tikka', 'Marinated fish pieces grilled in tandoor')
    ],
    'Healthy': [
        ('Quinoa Salad', 'Quinoa, cherry tomatoes, and cucumber'),
        ('Fruit Bowl', 'Assorted seasonal fresh fruits'),
        ('Kale Salad', 'Chopped kale with lemon vinaigrette'),
        ('Protein Bowl', 'Chicken breast, broccoli, and brown rice'),
        ('Zucchini Noodles', 'Spiralized zucchini with pesto sauce'),
        ('Boiled Eggs', 'Two hard boiled eggs with pepper'),
        ('Oatmeal', 'Cooked oats with almond milk and nuts'),
        ('Smoothie Bowl', 'Thick mixed berry smoothie topped with seeds'),
        ('Grilled Salmon', 'Salmon fillet with minimal oil and herbs'),
        ('Veggie Wrap', 'Whole wheat wrap with fresh leafy greens')
    ],
    'Popular': [
        ('French Fries', 'Crispy golden potato fries'),
        ('Nachos', 'Tortilla chips toppe with cheese and jalapeños'),
        ('Chicken Wings', 'Spicy buffalo style wings with dip'),
        ('Tacos', 'Hard shell tortillas with ground beef'),
        ('Onion Rings', 'Crispy fried onion slices'),
        ('Garlic Bread', 'Baguette slices topped with garlic butter'),
        ('Spring Rolls', 'Crispy wrappers stuffed with vegetables'),
        ('Dim Sum', 'Steamed dumplings with chicken and shrimp'),
        ('Momos', 'Tibetan style steamed dumplings'),
        ('Falafel', 'Fried chickpea balls with hummus')
    ]
}

images = [
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
    'https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?w=400',
    'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=400',
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    'https://images.unsplash.com/photo-1623065422902-30a2d299bbe4?w=400',
    'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400',
    'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
    'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
    'https://images.unsplash.com/photo-1550547660-d9450f859349?w=400',
    'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400',
    'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=400',
    'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=400',
    'https://images.unsplash.com/photo-1562802378-063ec186a863?w=400',
    'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',
    'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400',
    'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',
    'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400',
    'https://images.unsplash.com/photo-1574653853027-5382a3d23a15?w=400',
    'https://images.unsplash.com/photo-1603046891744-76e6300f82ef?w=400',
    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400',
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
    'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=400',
    'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
    'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',
    'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400',
    'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400',
    'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400',
    'https://images.unsplash.com/photo-1488900128323-21503983a07e?w=400'
]

dart_items = []
id_counter = 100

for cat, itms in categories_data.items():
    for name, desc in itms:
        price = random.randint(150, 899)
        rating = round(random.uniform(4.0, 5.0), 1)
        reviewCount = random.randint(50, 999)
        calories = random.randint(150, 900)
        prepTime = random.randint(5, 45)
        imgUrl = random.choice(images)
        s = f"""    FoodItem(
      id: '{id_counter}',
      name: '{name.replace("'", "\\'")}',
      description: '{desc.replace("'", "\\'")}',
      imageUrl: '{imgUrl}',
      price: {price}.00,
      rating: {rating},
      reviewCount: {reviewCount},
      category: '{cat}',
      calories: {calories},
      prepTimeMinutes: {prepTime},
    ),"""
        dart_items.append(s)
        id_counter += 1

output_dart = "\n".join(dart_items)

with open('lib/data/food_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r'static const List<FoodItem> items = \[(.*?)\n  \];\n\n  // ── Filters'
match = re.search(pattern, content, re.DOTALL)
if match:
    new_content = content.replace(match.group(1), "\n" + output_dart)
    with open('lib/data/food_data.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Done generating 110 items.")
else:
    print("Pattern not found")
