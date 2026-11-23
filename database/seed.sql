-- Données de départ Student Cook — écrites et vérifiées à la main.
-- Exécuté par database/init.php juste après schema.sql (même transaction).
--
-- Conventions :
--   - price_per_unit en centimes : par kg (unit = 'kg'), par litre ('L') ou par pièce ('unité').
--   - quantity entière : grammes si kg, millilitres si L, nombre de pièces si unité.
--   - Les ingrédients d'une recette sont retrouvés PAR LEUR NOM : une faute de frappe
--     donne NULL, la contrainte NOT NULL échoue et init.php s'arrête (pas d'erreur silencieuse).
--   - Drapeaux régime déclaratifs (0/1). Halal = 0 pour porc (lardons, jambon) ou alcool (vin) ;
--     viandes supposées achetées halal. Bouillon cube et sauce soja : considérés avec gluten.
--   - Planning et cases cochées : vides (aucune ligne dans meal_planning ni shopping_check).
--   - Pas de « Pâtes carbonara » : le nom doit rester libre pour le test CN1.

-- ===========================================================================
-- Ingrédients (référentiel fixe, 6 rayons)
-- ===========================================================================
INSERT INTO ingredients (name, aisle, price_per_unit, unit) VALUES
    -- Fruits & Légumes
    ('Tomates',                    'Fruits & Légumes',    299, 'kg'),
    ('Oignons',                    'Fruits & Légumes',    199, 'kg'),
    ('Ail',                        'Fruits & Légumes',    990, 'kg'),
    ('Carottes',                   'Fruits & Légumes',    149, 'kg'),
    ('Courgettes',                 'Fruits & Légumes',    299, 'kg'),
    ('Pommes de terre',            'Fruits & Légumes',    149, 'kg'),
    ('Poivrons',                   'Fruits & Légumes',    399, 'kg'),
    ('Champignons de Paris',       'Fruits & Légumes',    499, 'kg'),
    ('Bananes',                    'Fruits & Légumes',    199, 'kg'),
    ('Citrons',                    'Fruits & Légumes',     50, 'unité'),
    ('Concombre',                  'Fruits & Légumes',     99, 'unité'),
    ('Salade verte',               'Fruits & Légumes',     99, 'unité'),
    -- Épicerie
    ('Pâtes',                      'Épicerie',            159, 'kg'),
    ('Riz',                        'Épicerie',            199, 'kg'),
    ('Lentilles corail',           'Épicerie',            349, 'kg'),
    ('Pois chiches en conserve',   'Épicerie',            299, 'kg'),
    ('Tomates concassées',         'Épicerie',            249, 'kg'),
    ('Pesto',                      'Épicerie',           1290, 'kg'),
    ('Thon en conserve',           'Épicerie',           1590, 'kg'),
    ('Lait de coco',               'Épicerie',            399, 'L'),
    ('Huile d''olive',             'Épicerie',            999, 'L'),
    ('Sauce soja',                 'Épicerie',            699, 'L'),
    ('Farine de blé',              'Épicerie',            109, 'kg'),
    ('Curry en poudre',            'Épicerie',           2500, 'kg'),
    ('Tortillas de blé',           'Épicerie',             35, 'unité'),
    -- Frais
    ('Œufs',                       'Frais',                30, 'unité'),
    ('Lait',                       'Frais',               109, 'L'),
    ('Beurre',                     'Frais',               999, 'kg'),
    ('Crème fraîche',              'Frais',               449, 'L'),
    ('Parmesan',                   'Frais',              2490, 'kg'),
    ('Emmental râpé',              'Frais',               899, 'kg'),
    ('Yaourt nature',              'Frais',                25, 'unité'),
    ('Tofu nature',                'Frais',               899, 'kg'),
    -- Surgelés
    ('Petits pois surgelés',       'Surgelés',            299, 'kg'),
    ('Épinards surgelés',          'Surgelés',            249, 'kg'),
    ('Poêlée de légumes surgelée', 'Surgelés',            349, 'kg'),
    ('Filets de colin surgelés',   'Surgelés',            999, 'kg'),
    -- Viandes & Poissons
    ('Blanc de poulet',            'Viandes & Poissons', 1099, 'kg'),
    ('Bœuf haché',                 'Viandes & Poissons', 1199, 'kg'),
    ('Lardons',                    'Viandes & Poissons', 1190, 'kg'),
    ('Jambon blanc',               'Viandes & Poissons', 1290, 'kg'),
    -- Autres
    ('Bouillon cube de légumes',   'Autres',               15, 'unité'),
    ('Vin blanc',                  'Autres',              499, 'L'),
    ('Sel',                        'Autres',               89, 'kg');

-- ===========================================================================
-- Recettes
-- Colonnes : id, nom, temps (min), portions, végétarien, végan, sans gluten, halal
-- ===========================================================================
INSERT INTO recipes (id, name, prep_time, servings, is_vegetarian, is_vegan, is_gluten_free, is_halal) VALUES
    ( 1, 'Pâtes au pesto',                          15, 1, 1, 0, 0, 1),
    ( 2, 'Salade de pâtes',                         20, 2, 0, 0, 0, 1),
    ( 3, 'Dahl de lentilles corail',                30, 3, 1, 1, 1, 1),
    ( 4, 'Omelette aux champignons',                15, 1, 1, 0, 1, 1),
    ( 5, 'Riz cantonais',                           25, 2, 0, 0, 0, 0),
    ( 6, 'Pâtes crème, lardons et champignons',     20, 2, 0, 0, 0, 0),
    ( 7, 'Curry de pois chiches aux épinards',      30, 3, 1, 1, 1, 1),
    ( 8, 'Poulet curry coco et riz',                35, 2, 0, 0, 1, 1),
    ( 9, 'Hachis parmentier',                       60, 4, 0, 0, 1, 1),
    (10, 'Gratin de courgettes',                    45, 3, 1, 0, 1, 1),
    (11, 'Soupe de légumes',                        35, 2, 1, 1, 0, 1),
    (12, 'Wraps au poulet',                         20, 2, 0, 0, 0, 1),
    (13, 'Crêpes à la banane',                      30, 2, 1, 0, 0, 1),
    (14, 'Poêlée de légumes au tofu',               20, 2, 1, 1, 0, 1),
    (15, 'Colin et pommes vapeur',                  25, 2, 0, 0, 1, 1),
    (16, 'Risotto aux champignons',                 40, 3, 1, 0, 0, 0),
    (17, 'Pâtes bolognaise',                        35, 4, 0, 0, 0, 1),
    (18, 'Quiche lorraine',                         55, 4, 0, 0, 0, 0),
    (19, 'Shakshuka',                               25, 2, 1, 0, 1, 1),
    (20, 'Bowl riz et pois chiches',                20, 2, 1, 1, 1, 1),
    (21, 'Steak haché, frites au four et salade',   30, 1, 0, 0, 1, 1),
    (22, 'Quesadillas au fromage',                  15, 2, 1, 0, 0, 1),
    (23, 'Gratin dauphinois',                       60, 3, 1, 0, 1, 1),
    (24, 'Salade de riz au thon',                   20, 2, 0, 0, 1, 1),
    (25, 'Pâtes aux légumes du soleil',             25, 2, 1, 1, 0, 1);

-- ===========================================================================
-- Ingrédients des recettes (recipe_id, ingrédient retrouvé par son nom, quantité)
-- ===========================================================================
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES
    -- 1. Pâtes au pesto (1 portion) — 200 g de pâtes imposés par TESTS.md
    ( 1, (SELECT id FROM ingredients WHERE name = 'Pâtes'),            200),
    ( 1, (SELECT id FROM ingredients WHERE name = 'Pesto'),             60),
    ( 1, (SELECT id FROM ingredients WHERE name = 'Parmesan'),          10),
    -- 2. Salade de pâtes (2 portions) — 150 g de pâtes imposés par TESTS.md
    ( 2, (SELECT id FROM ingredients WHERE name = 'Pâtes'),            150),
    ( 2, (SELECT id FROM ingredients WHERE name = 'Tomates'),          200),
    ( 2, (SELECT id FROM ingredients WHERE name = 'Concombre'),          1),
    ( 2, (SELECT id FROM ingredients WHERE name = 'Thon en conserve'), 140),
    ( 2, (SELECT id FROM ingredients WHERE name = 'Huile d''olive'),    20),
    -- 3. Dahl de lentilles corail (3 portions)
    ( 3, (SELECT id FROM ingredients WHERE name = 'Lentilles corail'),  250),
    ( 3, (SELECT id FROM ingredients WHERE name = 'Lait de coco'),      400),
    ( 3, (SELECT id FROM ingredients WHERE name = 'Tomates concassées'), 400),
    ( 3, (SELECT id FROM ingredients WHERE name = 'Oignons'),           100),
    ( 3, (SELECT id FROM ingredients WHERE name = 'Ail'),                10),
    ( 3, (SELECT id FROM ingredients WHERE name = 'Curry en poudre'),     5),
    ( 3, (SELECT id FROM ingredients WHERE name = 'Riz'),               225),
    -- 4. Omelette aux champignons (1 portion)
    ( 4, (SELECT id FROM ingredients WHERE name = 'Œufs'),                3),
    ( 4, (SELECT id FROM ingredients WHERE name = 'Champignons de Paris'), 150),
    ( 4, (SELECT id FROM ingredients WHERE name = 'Beurre'),             10),
    ( 4, (SELECT id FROM ingredients WHERE name = 'Emmental râpé'),      30),
    -- 5. Riz cantonais (2 portions)
    ( 5, (SELECT id FROM ingredients WHERE name = 'Riz'),               200),
    ( 5, (SELECT id FROM ingredients WHERE name = 'Œufs'),                2),
    ( 5, (SELECT id FROM ingredients WHERE name = 'Petits pois surgelés'), 150),
    ( 5, (SELECT id FROM ingredients WHERE name = 'Jambon blanc'),      100),
    ( 5, (SELECT id FROM ingredients WHERE name = 'Sauce soja'),         20),
    ( 5, (SELECT id FROM ingredients WHERE name = 'Oignons'),            50),
    -- 6. Pâtes crème, lardons et champignons (2 portions)
    ( 6, (SELECT id FROM ingredients WHERE name = 'Pâtes'),            250),
    ( 6, (SELECT id FROM ingredients WHERE name = 'Lardons'),          150),
    ( 6, (SELECT id FROM ingredients WHERE name = 'Crème fraîche'),    200),
    ( 6, (SELECT id FROM ingredients WHERE name = 'Champignons de Paris'), 200),
    ( 6, (SELECT id FROM ingredients WHERE name = 'Oignons'),           50),
    -- 7. Curry de pois chiches aux épinards (3 portions)
    ( 7, (SELECT id FROM ingredients WHERE name = 'Pois chiches en conserve'), 400),
    ( 7, (SELECT id FROM ingredients WHERE name = 'Lait de coco'),      400),
    ( 7, (SELECT id FROM ingredients WHERE name = 'Tomates concassées'), 400),
    ( 7, (SELECT id FROM ingredients WHERE name = 'Épinards surgelés'), 200),
    ( 7, (SELECT id FROM ingredients WHERE name = 'Oignons'),           100),
    ( 7, (SELECT id FROM ingredients WHERE name = 'Curry en poudre'),    10),
    ( 7, (SELECT id FROM ingredients WHERE name = 'Riz'),               225),
    -- 8. Poulet curry coco et riz (2 portions)
    ( 8, (SELECT id FROM ingredients WHERE name = 'Blanc de poulet'),  300),
    ( 8, (SELECT id FROM ingredients WHERE name = 'Lait de coco'),      200),
    ( 8, (SELECT id FROM ingredients WHERE name = 'Curry en poudre'),    10),
    ( 8, (SELECT id FROM ingredients WHERE name = 'Oignons'),           100),
    ( 8, (SELECT id FROM ingredients WHERE name = 'Riz'),               150),
    -- 9. Hachis parmentier (4 portions)
    ( 9, (SELECT id FROM ingredients WHERE name = 'Pommes de terre'),  1000),
    ( 9, (SELECT id FROM ingredients WHERE name = 'Bœuf haché'),        500),
    ( 9, (SELECT id FROM ingredients WHERE name = 'Oignons'),           100),
    ( 9, (SELECT id FROM ingredients WHERE name = 'Lait'),              200),
    ( 9, (SELECT id FROM ingredients WHERE name = 'Beurre'),             40),
    ( 9, (SELECT id FROM ingredients WHERE name = 'Emmental râpé'),      80),
    -- 10. Gratin de courgettes (3 portions)
    (10, (SELECT id FROM ingredients WHERE name = 'Courgettes'),        800),
    (10, (SELECT id FROM ingredients WHERE name = 'Œufs'),                3),
    (10, (SELECT id FROM ingredients WHERE name = 'Crème fraîche'),     200),
    (10, (SELECT id FROM ingredients WHERE name = 'Emmental râpé'),     100),
    (10, (SELECT id FROM ingredients WHERE name = 'Ail'),                10),
    -- 11. Soupe de légumes (2 portions)
    (11, (SELECT id FROM ingredients WHERE name = 'Pommes de terre'),   400),
    (11, (SELECT id FROM ingredients WHERE name = 'Carottes'),          400),
    (11, (SELECT id FROM ingredients WHERE name = 'Courgettes'),        300),
    (11, (SELECT id FROM ingredients WHERE name = 'Oignons'),           100),
    (11, (SELECT id FROM ingredients WHERE name = 'Bouillon cube de légumes'), 2),
    (11, (SELECT id FROM ingredients WHERE name = 'Huile d''olive'),     10),
    -- 12. Wraps au poulet (2 portions)
    (12, (SELECT id FROM ingredients WHERE name = 'Tortillas de blé'),    4),
    (12, (SELECT id FROM ingredients WHERE name = 'Blanc de poulet'),  250),
    (12, (SELECT id FROM ingredients WHERE name = 'Salade verte'),        1),
    (12, (SELECT id FROM ingredients WHERE name = 'Tomates'),           150),
    (12, (SELECT id FROM ingredients WHERE name = 'Yaourt nature'),       1),
    -- 13. Crêpes à la banane (2 portions)
    (13, (SELECT id FROM ingredients WHERE name = 'Farine de blé'),     250),
    (13, (SELECT id FROM ingredients WHERE name = 'Œufs'),                3),
    (13, (SELECT id FROM ingredients WHERE name = 'Lait'),              500),
    (13, (SELECT id FROM ingredients WHERE name = 'Beurre'),             30),
    (13, (SELECT id FROM ingredients WHERE name = 'Bananes'),           400),
    -- 14. Poêlée de légumes au tofu (2 portions)
    (14, (SELECT id FROM ingredients WHERE name = 'Tofu nature'),       200),
    (14, (SELECT id FROM ingredients WHERE name = 'Poêlée de légumes surgelée'), 500),
    (14, (SELECT id FROM ingredients WHERE name = 'Sauce soja'),         30),
    (14, (SELECT id FROM ingredients WHERE name = 'Riz'),               150),
    -- 15. Colin et pommes vapeur (2 portions)
    (15, (SELECT id FROM ingredients WHERE name = 'Filets de colin surgelés'), 300),
    (15, (SELECT id FROM ingredients WHERE name = 'Pommes de terre'),   400),
    (15, (SELECT id FROM ingredients WHERE name = 'Beurre'),             20),
    (15, (SELECT id FROM ingredients WHERE name = 'Citrons'),             1),
    -- 16. Risotto aux champignons (3 portions)
    (16, (SELECT id FROM ingredients WHERE name = 'Riz'),               250),
    (16, (SELECT id FROM ingredients WHERE name = 'Champignons de Paris'), 300),
    (16, (SELECT id FROM ingredients WHERE name = 'Vin blanc'),         100),
    (16, (SELECT id FROM ingredients WHERE name = 'Oignons'),           100),
    (16, (SELECT id FROM ingredients WHERE name = 'Parmesan'),           50),
    (16, (SELECT id FROM ingredients WHERE name = 'Bouillon cube de légumes'), 2),
    (16, (SELECT id FROM ingredients WHERE name = 'Beurre'),             30),
    -- 17. Pâtes bolognaise (4 portions)
    (17, (SELECT id FROM ingredients WHERE name = 'Pâtes'),            400),
    (17, (SELECT id FROM ingredients WHERE name = 'Bœuf haché'),        400),
    (17, (SELECT id FROM ingredients WHERE name = 'Tomates concassées'), 800),
    (17, (SELECT id FROM ingredients WHERE name = 'Oignons'),           100),
    (17, (SELECT id FROM ingredients WHERE name = 'Carottes'),          100),
    (17, (SELECT id FROM ingredients WHERE name = 'Huile d''olive'),     20),
    -- 18. Quiche lorraine (4 portions)
    (18, (SELECT id FROM ingredients WHERE name = 'Farine de blé'),     200),
    (18, (SELECT id FROM ingredients WHERE name = 'Beurre'),            100),
    (18, (SELECT id FROM ingredients WHERE name = 'Œufs'),                3),
    (18, (SELECT id FROM ingredients WHERE name = 'Crème fraîche'),     200),
    (18, (SELECT id FROM ingredients WHERE name = 'Lardons'),          200),
    (18, (SELECT id FROM ingredients WHERE name = 'Emmental râpé'),      80),
    -- 19. Shakshuka (2 portions)
    (19, (SELECT id FROM ingredients WHERE name = 'Œufs'),                4),
    (19, (SELECT id FROM ingredients WHERE name = 'Tomates concassées'), 400),
    (19, (SELECT id FROM ingredients WHERE name = 'Poivrons'),          200),
    (19, (SELECT id FROM ingredients WHERE name = 'Oignons'),           100),
    (19, (SELECT id FROM ingredients WHERE name = 'Ail'),                10),
    (19, (SELECT id FROM ingredients WHERE name = 'Huile d''olive'),     15),
    -- 20. Bowl riz et pois chiches (2 portions)
    (20, (SELECT id FROM ingredients WHERE name = 'Riz'),               150),
    (20, (SELECT id FROM ingredients WHERE name = 'Pois chiches en conserve'), 250),
    (20, (SELECT id FROM ingredients WHERE name = 'Carottes'),          150),
    (20, (SELECT id FROM ingredients WHERE name = 'Concombre'),           1),
    (20, (SELECT id FROM ingredients WHERE name = 'Citrons'),             1),
    (20, (SELECT id FROM ingredients WHERE name = 'Huile d''olive'),     20),
    -- 21. Steak haché, frites au four et salade (1 portion)
    (21, (SELECT id FROM ingredients WHERE name = 'Bœuf haché'),        200),
    (21, (SELECT id FROM ingredients WHERE name = 'Pommes de terre'),   300),
    (21, (SELECT id FROM ingredients WHERE name = 'Huile d''olive'),     30),
    (21, (SELECT id FROM ingredients WHERE name = 'Salade verte'),        1),
    -- 22. Quesadillas au fromage (2 portions)
    (22, (SELECT id FROM ingredients WHERE name = 'Tortillas de blé'),    4),
    (22, (SELECT id FROM ingredients WHERE name = 'Emmental râpé'),     150),
    (22, (SELECT id FROM ingredients WHERE name = 'Poivrons'),          150),
    (22, (SELECT id FROM ingredients WHERE name = 'Tomates'),           100),
    -- 23. Gratin dauphinois (3 portions)
    (23, (SELECT id FROM ingredients WHERE name = 'Pommes de terre'),  1000),
    (23, (SELECT id FROM ingredients WHERE name = 'Lait'),              500),
    (23, (SELECT id FROM ingredients WHERE name = 'Crème fraîche'),     250),
    (23, (SELECT id FROM ingredients WHERE name = 'Ail'),                10),
    (23, (SELECT id FROM ingredients WHERE name = 'Beurre'),             20),
    -- 24. Salade de riz au thon (2 portions)
    (24, (SELECT id FROM ingredients WHERE name = 'Riz'),               150),
    (24, (SELECT id FROM ingredients WHERE name = 'Thon en conserve'),  140),
    (24, (SELECT id FROM ingredients WHERE name = 'Tomates'),           200),
    (24, (SELECT id FROM ingredients WHERE name = 'Œufs'),                2),
    (24, (SELECT id FROM ingredients WHERE name = 'Huile d''olive'),     20),
    -- 25. Pâtes aux légumes du soleil (2 portions)
    (25, (SELECT id FROM ingredients WHERE name = 'Pâtes'),            200),
    (25, (SELECT id FROM ingredients WHERE name = 'Courgettes'),        300),
    (25, (SELECT id FROM ingredients WHERE name = 'Poivrons'),          200),
    (25, (SELECT id FROM ingredients WHERE name = 'Tomates'),           200),
    (25, (SELECT id FROM ingredients WHERE name = 'Ail'),                10),
    (25, (SELECT id FROM ingredients WHERE name = 'Huile d''olive'),     20);

-- ===========================================================================
-- Étapes des recettes (recipe_id, numéro à partir de 1, description)
-- ===========================================================================
INSERT INTO recipe_steps (recipe_id, step_number, description) VALUES
    ( 1, 1, 'Cuire les pâtes dans une grande casserole d''eau bouillante salée.'),
    ( 1, 2, 'Égoutter en gardant un fond d''eau de cuisson.'),
    ( 1, 3, 'Mélanger avec le pesto et un peu d''eau de cuisson, parsemer de parmesan.'),

    ( 2, 1, 'Cuire les pâtes, les égoutter et les refroidir sous l''eau froide.'),
    ( 2, 2, 'Couper les tomates et le concombre en dés, émietter le thon.'),
    ( 2, 3, 'Mélanger le tout avec l''huile d''olive, saler et poivrer.'),

    ( 3, 1, 'Faire revenir l''oignon et l''ail émincés avec le curry.'),
    ( 3, 2, 'Ajouter les lentilles rincées, les tomates concassées et le lait de coco.'),
    ( 3, 3, 'Laisser mijoter 20 minutes en remuant, ajouter de l''eau si besoin.'),
    ( 3, 4, 'Servir avec le riz cuit à part.'),

    ( 4, 1, 'Émincer les champignons et les faire dorer dans le beurre.'),
    ( 4, 2, 'Battre les œufs avec le fromage, saler et poivrer.'),
    ( 4, 3, 'Verser sur les champignons et cuire à feu doux jusqu''à la prise.'),

    ( 5, 1, 'Cuire le riz et le laisser refroidir.'),
    ( 5, 2, 'Faire revenir l''oignon, ajouter les petits pois et le jambon en dés.'),
    ( 5, 3, 'Ajouter les œufs battus, remuer jusqu''à ce qu''ils soient cuits.'),
    ( 5, 4, 'Ajouter le riz et la sauce soja, faire sauter 3 minutes.'),

    ( 6, 1, 'Cuire les pâtes.'),
    ( 6, 2, 'Faire revenir les lardons, l''oignon et les champignons émincés.'),
    ( 6, 3, 'Ajouter la crème, laisser réduire 2 minutes et mélanger aux pâtes.'),

    ( 7, 1, 'Faire revenir l''oignon émincé avec le curry.'),
    ( 7, 2, 'Ajouter les pois chiches égouttés, les tomates et le lait de coco.'),
    ( 7, 3, 'Ajouter les épinards et laisser mijoter 15 minutes.'),
    ( 7, 4, 'Servir avec le riz cuit à part.'),

    ( 8, 1, 'Couper le poulet en morceaux et le faire dorer avec l''oignon.'),
    ( 8, 2, 'Ajouter le curry et le lait de coco, laisser mijoter 15 minutes.'),
    ( 8, 3, 'Servir avec le riz cuit à part.'),

    ( 9, 1, 'Cuire les pommes de terre à l''eau, les écraser avec le lait et le beurre.'),
    ( 9, 2, 'Faire revenir l''oignon et le bœuf haché.'),
    ( 9, 3, 'Mettre la viande dans un plat, couvrir de purée et d''emmental.'),
    ( 9, 4, 'Gratiner 20 minutes au four à 200 °C.'),

    (10, 1, 'Couper les courgettes en rondelles et les faire revenir avec l''ail.'),
    (10, 2, 'Battre les œufs avec la crème, saler et poivrer.'),
    (10, 3, 'Mettre les courgettes dans un plat, verser le mélange, couvrir d''emmental.'),
    (10, 4, 'Cuire 30 minutes au four à 180 °C.'),

    (11, 1, 'Éplucher et couper tous les légumes en morceaux.'),
    (11, 2, 'Faire revenir l''oignon dans l''huile, ajouter les légumes.'),
    (11, 3, 'Couvrir d''eau, ajouter les bouillons cubes et cuire 25 minutes.'),
    (11, 4, 'Mixer la soupe.'),

    (12, 1, 'Couper le poulet en lanières et le faire cuire à la poêle.'),
    (12, 2, 'Couper les tomates et laver la salade.'),
    (12, 3, 'Garnir les tortillas de poulet, salade, tomates et yaourt, puis rouler.'),

    (13, 1, 'Mélanger la farine et les œufs, ajouter le lait petit à petit, puis le beurre fondu.'),
    (13, 2, 'Laisser reposer la pâte 10 minutes.'),
    (13, 3, 'Cuire les crêpes dans une poêle chaude.'),
    (13, 4, 'Garnir de rondelles de banane.'),

    (14, 1, 'Cuire le riz.'),
    (14, 2, 'Couper le tofu en dés et le faire dorer à la poêle.'),
    (14, 3, 'Ajouter la poêlée de légumes et la sauce soja, cuire 10 minutes.'),

    (15, 1, 'Cuire les pommes de terre à la vapeur ou à l''eau, 20 minutes.'),
    (15, 2, 'Cuire les filets de colin à la poêle avec le beurre.'),
    (15, 3, 'Servir avec le jus du citron.'),

    (16, 1, 'Préparer 75 cL de bouillon avec les bouillons cubes.'),
    (16, 2, 'Faire revenir l''oignon et les champignons dans le beurre, ajouter le riz.'),
    (16, 3, 'Déglacer au vin blanc, puis ajouter le bouillon louche par louche en remuant.'),
    (16, 4, 'Hors du feu, ajouter le parmesan.'),

    (17, 1, 'Faire revenir l''oignon et la carotte hachés dans l''huile.'),
    (17, 2, 'Ajouter le bœuf haché, puis les tomates concassées, mijoter 20 minutes.'),
    (17, 3, 'Cuire les pâtes et servir avec la sauce.'),

    (18, 1, 'Mélanger la farine, le beurre et un peu d''eau pour former la pâte, l''étaler dans un moule.'),
    (18, 2, 'Faire revenir les lardons.'),
    (18, 3, 'Battre les œufs avec la crème, ajouter les lardons et l''emmental.'),
    (18, 4, 'Verser sur la pâte et cuire 35 minutes au four à 180 °C.'),

    (19, 1, 'Faire revenir l''oignon, l''ail et les poivrons dans l''huile.'),
    (19, 2, 'Ajouter les tomates concassées et laisser mijoter 10 minutes.'),
    (19, 3, 'Creuser des puits, y casser les œufs, couvrir et cuire 5 minutes.'),

    (20, 1, 'Cuire le riz.'),
    (20, 2, 'Râper les carottes, couper le concombre, égoutter les pois chiches.'),
    (20, 3, 'Disposer le tout dans des bols, assaisonner avec l''huile et le jus du citron.'),

    (21, 1, 'Couper les pommes de terre en frites, les mélanger avec l''huile.'),
    (21, 2, 'Cuire les frites 25 minutes au four à 220 °C.'),
    (21, 3, 'Cuire le steak à la poêle et servir avec la salade.'),

    (22, 1, 'Couper les poivrons et les tomates en petits dés.'),
    (22, 2, 'Garnir une tortilla de fromage et de légumes, couvrir d''une autre tortilla.'),
    (22, 3, 'Dorer 3 minutes de chaque côté à la poêle, couper en parts.'),

    (23, 1, 'Éplucher et couper les pommes de terre en fines rondelles.'),
    (23, 2, 'Frotter un plat avec l''ail et le beurre, y ranger les pommes de terre.'),
    (23, 3, 'Verser le lait et la crème mélangés, saler et poivrer.'),
    (23, 4, 'Cuire 50 minutes au four à 180 °C.'),

    (24, 1, 'Cuire le riz et les œufs durs (10 minutes), laisser refroidir.'),
    (24, 2, 'Couper les tomates et les œufs, émietter le thon.'),
    (24, 3, 'Mélanger le tout avec l''huile d''olive.'),

    (25, 1, 'Cuire les pâtes.'),
    (25, 2, 'Couper les courgettes, les poivrons et les tomates en dés.'),
    (25, 3, 'Faire revenir les légumes avec l''ail dans l''huile 10 minutes.'),
    (25, 4, 'Mélanger avec les pâtes.');
