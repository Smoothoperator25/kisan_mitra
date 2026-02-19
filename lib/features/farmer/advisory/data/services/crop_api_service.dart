import '../models/crop_model.dart';

class CropApiService {
  Future<List<Crop>> getGlobalCrops() async {
    // Return curated list of 100 Indian/Maharashtra crops directly
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // brief loading indicator
    return _getMockCrops();
  }

  // 100 most planted crops in Maharashtra & India
  List<Crop> _getMockCrops() {
    return [
      // ── CEREALS ──────────────────────────────────────────
      Crop(
        id: 'c01',
        name: 'Paddy (Rice)',
        scientificName: 'Oryza sativa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Rice_Fields_in_Comilla.jpg/800px-Rice_Fields_in_Comilla.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 50),
        growthStages: [
          'Seedling',
          'Transplanting',
          'Tillering',
          'Panicle Initiation',
          'Flowering',
          'Maturity',
        ],
      ),
      Crop(
        id: 'c02',
        name: 'Wheat',
        scientificName: 'Triticum aestivum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Vehn%C3%A4pelto_6.jpg/800px-Vehn%C3%A4pelto_6.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 120, p: 60, k: 40),
        growthStages: [
          'Seedling',
          'Tillering',
          'Jointing',
          'Booting',
          'Flowering',
          'Maturity',
        ],
      ),
      Crop(
        id: 'c03',
        name: 'Jowar (Sorghum)',
        scientificName: 'Sorghum bicolor',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Sorghum_bicolor_003.jpg/800px-Sorghum_bicolor_003.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 40),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Panicle Initiation',
          'Flowering',
          'Grain Fill',
          'Maturity',
        ],
      ),
      Crop(
        id: 'c04',
        name: 'Bajra (Pearl Millet)',
        scientificName: 'Pennisetum glaucum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Pearl_Millet_on_the_vine.jpg/800px-Pearl_Millet_on_the_vine.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 30),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Panicle Emergence',
          'Flowering',
          'Grain Fill',
          'Maturity',
        ],
      ),
      Crop(
        id: 'c05',
        name: 'Maize (Corn)',
        scientificName: 'Zea mays',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Maize_ear_closeup.jpg/800px-Maize_ear_closeup.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 150, p: 60, k: 60),
        growthStages: [
          'Seedling',
          'Knee High',
          'Tasseling',
          'Silking',
          'Dough',
          'Maturity',
        ],
      ),
      Crop(
        id: 'c06',
        name: 'Ragi (Finger Millet)',
        scientificName: 'Eleusine coracana',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Eleusine_coracana_at_Kadavoor.jpg/800px-Eleusine_coracana_at_Kadavoor.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 30),
        growthStages: [
          'Seedling',
          'Tillering',
          'Panicle Initiation',
          'Flowering',
          'Maturity',
        ],
      ),
      Crop(
        id: 'c07',
        name: 'Barley',
        scientificName: 'Hordeum vulgare',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Barley_crop.jpg/800px-Barley_crop.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 30),
        growthStages: [
          'Seedling',
          'Tillering',
          'Jointing',
          'Heading',
          'Maturity',
        ],
      ),
      Crop(
        id: 'c08',
        name: 'Oats',
        scientificName: 'Avena sativa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Hafer.jpg/800px-Hafer.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 30),
        growthStages: [
          'Seedling',
          'Tillering',
          'Stem Elongation',
          'Heading',
          'Maturity',
        ],
      ),

      // ── PULSES / LEGUMES ──────────────────────────────────
      Crop(
        id: 'l01',
        name: 'Tur (Pigeon Pea)',
        scientificName: 'Cajanus cajan',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Pigeon_Peas.jpg/800px-Pigeon_Peas.jpg',
        category: 'Legume',
        nutrientRequirement: NPKRequirement(n: 20, p: 60, k: 30),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Flowering',
          'Pod Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'l02',
        name: 'Moong (Green Gram)',
        scientificName: 'Vigna radiata',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Mung_beans.jpg/800px-Mung_beans.jpg',
        category: 'Legume',
        nutrientRequirement: NPKRequirement(n: 20, p: 50, k: 30),
        growthStages: [
          'Germination',
          'Seedling',
          'Flowering',
          'Pod Fill',
          'Maturity',
        ],
      ),
      Crop(
        id: 'l03',
        name: 'Urad (Black Gram)',
        scientificName: 'Vigna mungo',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Vigna_mungo.jpg/800px-Vigna_mungo.jpg',
        category: 'Legume',
        nutrientRequirement: NPKRequirement(n: 20, p: 50, k: 30),
        growthStages: [
          'Germination',
          'Seedling',
          'Flowering',
          'Pod Fill',
          'Maturity',
        ],
      ),
      Crop(
        id: 'l04',
        name: 'Chickpea (Gram)',
        scientificName: 'Cicer arietinum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Chickpeas_in_a_bowl.jpg/800px-Chickpeas_in_a_bowl.jpg',
        category: 'Legume',
        nutrientRequirement: NPKRequirement(n: 20, p: 60, k: 30),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Pod Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'l05',
        name: 'Masoor (Red Lentil)',
        scientificName: 'Lens culinaris',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Red_Lentils.jpg/800px-Red_Lentils.jpg',
        category: 'Legume',
        nutrientRequirement: NPKRequirement(n: 20, p: 50, k: 30),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Pod Fill',
          'Maturity',
        ],
      ),
      Crop(
        id: 'l06',
        name: 'Cowpea (Lobia)',
        scientificName: 'Vigna unguiculata',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Cowpea.jpg/800px-Cowpea.jpg',
        category: 'Legume',
        nutrientRequirement: NPKRequirement(n: 20, p: 50, k: 30),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Pod Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'l07',
        name: 'Horse Gram (Kulthi)',
        scientificName: 'Macrotyloma uniflorum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Horsegram.jpg/800px-Horsegram.jpg',
        category: 'Legume',
        nutrientRequirement: NPKRequirement(n: 20, p: 40, k: 20),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'l08',
        name: 'Soybean',
        scientificName: 'Glycine max',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Soybean_scenery.jpg/800px-Soybean_scenery.jpg',
        category: 'Legume',
        nutrientRequirement: NPKRequirement(n: 20, p: 80, k: 40),
        growthStages: [
          'Germination',
          'Seedling',
          'Vegetative',
          'Flowering',
          'Pod Fill',
          'Maturity',
        ],
      ),

      // ── OILSEEDS ──────────────────────────────────────────
      Crop(
        id: 'o01',
        name: 'Groundnut (Peanut)',
        scientificName: 'Arachis hypogaea',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Peanut_field.jpg/800px-Peanut_field.jpg',
        category: 'Oilseed',
        nutrientRequirement: NPKRequirement(n: 20, p: 60, k: 40),
        growthStages: [
          'Germination',
          'Seedling',
          'Flowering',
          'Pegging',
          'Pod Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'o02',
        name: 'Sunflower',
        scientificName: 'Helianthus annuus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Sunflower_in_the_field.jpg/800px-Sunflower_in_the_field.jpg',
        category: 'Oilseed',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 40),
        growthStages: [
          'Germination',
          'Vegetative',
          'Bud Stage',
          'Flowering',
          'Seed Fill',
          'Maturity',
        ],
      ),
      Crop(
        id: 'o03',
        name: 'Mustard (Rapeseed)',
        scientificName: 'Brassica juncea',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Mustard_field.jpg/800px-Mustard_field.jpg',
        category: 'Oilseed',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 40),
        growthStages: [
          'Germination',
          'Rosette',
          'Stem Elongation',
          'Flowering',
          'Pod Fill',
          'Maturity',
        ],
      ),
      Crop(
        id: 'o04',
        name: 'Sesame (Til)',
        scientificName: 'Sesamum indicum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Sesamum_indicum.jpg/800px-Sesamum_indicum.jpg',
        category: 'Oilseed',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 30),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Capsule Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'o05',
        name: 'Linseed (Flax)',
        scientificName: 'Linum usitatissimum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Blue_Flax_Flower.jpg/800px-Blue_Flax_Flower.jpg',
        category: 'Oilseed',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 30),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'o06',
        name: 'Castor',
        scientificName: 'Ricinus communis',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Ricinus_communis_-_castor_oil_plant.jpg/640px-Ricinus_communis_-_castor_oil_plant.jpg',
        category: 'Oilseed',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 40),
        growthStages: [
          'Germination',
          'Vegetative',
          'Spike Initiation',
          'Flowering',
          'Capsule Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'o07',
        name: 'Safflower',
        scientificName: 'Carthamus tinctorius',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Safflower2009.JPG/800px-Safflower2009.JPG',
        category: 'Oilseed',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 30),
        growthStages: [
          'Germination',
          'Rosette',
          'Stem Elongation',
          'Flowering',
          'Maturity',
        ],
      ),

      // ── COMMERCIAL / FIBER ────────────────────────────────
      Crop(
        id: 'com01',
        name: 'Cotton',
        scientificName: 'Gossypium hirsutum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Cotton_plant.jpg/800px-Cotton_plant.jpg',
        category: 'Fiber',
        nutrientRequirement: NPKRequirement(n: 120, p: 60, k: 60),
        growthStages: [
          'Germination',
          'Seedling',
          'Square Formation',
          'Flowering',
          'Boll Development',
          'Boll Opening',
        ],
      ),
      Crop(
        id: 'com02',
        name: 'Sugarcane',
        scientificName: 'Saccharum officinarum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Sugarcane_2.jpg/800px-Sugarcane_2.jpg',
        category: 'Commercial',
        nutrientRequirement: NPKRequirement(n: 250, p: 100, k: 120),
        growthStages: [
          'Germination',
          'Tillering',
          'Grand Growth',
          'Ripening',
          'Maturity',
        ],
      ),
      Crop(
        id: 'com03',
        name: 'Jute',
        scientificName: 'Corchorus olitorius',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/JuteField_bg110712.jpg/800px-JuteField_bg110712.jpg',
        category: 'Fiber',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 40),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'com04',
        name: 'Tobacco',
        scientificName: 'Nicotiana tabacum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Tabacum_xanthii.jpg/800px-Tabacum_xanthii.jpg',
        category: 'Commercial',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 80),
        growthStages: [
          'Nursery',
          'Transplanting',
          'Vegetative',
          'Topping',
          'Maturity',
        ],
      ),

      // ── VEGETABLES ────────────────────────────────────────
      Crop(
        id: 'v01',
        name: 'Tomato',
        scientificName: 'Solanum lycopersicum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/800px-Tomato_je.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 100, p: 60, k: 100),
        growthStages: [
          'Transplanting',
          'Vegetative',
          'Flowering',
          'Fruit Set',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v02',
        name: 'Onion',
        scientificName: 'Allium cepa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Onions_in_Field.jpg/800px-Onions_in_Field.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 80),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Bulb Initiation',
          'Bulb Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'v03',
        name: 'Potato',
        scientificName: 'Solanum tuberosum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Patates.jpg/800px-Patates.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 120, p: 80, k: 120),
        growthStages: [
          'Sprouting',
          'Vegetative',
          'Tuber Initiation',
          'Tuber Bulking',
          'Maturation',
        ],
      ),
      Crop(
        id: 'v04',
        name: 'Brinjal (Eggplant)',
        scientificName: 'Solanum melongena',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Aubergine.jpg/800px-Aubergine.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 100, p: 60, k: 60),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Flowering',
          'Fruit Set',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v05',
        name: 'Okra (Bhindi)',
        scientificName: 'Abelmoschus esculentus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Okra_fruits_growing_in_garden.jpg/800px-Okra_fruits_growing_in_garden.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 60),
        growthStages: [
          'Germination',
          'Seedling',
          'Vegetative',
          'Flowering',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v06',
        name: 'Chili (Hot Pepper)',
        scientificName: 'Capsicum annuum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Red_Hot_Chili_Pepper.jpg/800px-Red_Hot_Chili_Pepper.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 100, p: 60, k: 80),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Flowering',
          'Fruit Set',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v07',
        name: 'Capsicum (Bell Pepper)',
        scientificName: 'Capsicum annuum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Capsicum_pubescens_fruits.jpg/800px-Capsicum_pubescens_fruits.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 100, p: 60, k: 80),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Flowering',
          'Fruit Set',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v08',
        name: 'Cauliflower',
        scientificName: 'Brassica oleracea',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Chou-fleur_01.jpg/800px-Chou-fleur_01.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 100, p: 60, k: 60),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Curd Initiation',
          'Curd Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v09',
        name: 'Cabbage',
        scientificName: 'Brassica oleracea var. capitata',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Kale-Bundle.jpg/800px-Kale-Bundle.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 100, p: 60, k: 60),
        growthStages: ['Seedling', 'Vegetative', 'Head Formation', 'Maturity'],
      ),
      Crop(
        id: 'v10',
        name: 'Cucumber',
        scientificName: 'Cucumis sativus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Cucumbers_on_a_vine.jpg/800px-Cucumbers_on_a_vine.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 60),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Fruit Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v11',
        name: 'Bitter Gourd (Karela)',
        scientificName: 'Momordica charantia',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Bittermelon_2009.jpg/800px-Bittermelon_2009.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 60),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Fruit Set',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v12',
        name: 'Bottle Gourd (Lauki)',
        scientificName: 'Lagenaria siceraria',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Lagenaria_siceraria_fruit.jpg/800px-Lagenaria_siceraria_fruit.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 60),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Fruit Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v13',
        name: 'Pumpkin',
        scientificName: 'Cucurbita pepo',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/FrenchMarketPumpkins.jpg/800px-FrenchMarketPumpkins.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 60),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Fruit Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v14',
        name: 'Watermelon',
        scientificName: 'Citrullus lanatus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_Watermelon_and_cross_section.jpg/800px-PNG_Watermelon_and_cross_section.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 80),
        growthStages: [
          'Germination',
          'Vine Development',
          'Flowering',
          'Fruit Set',
          'Ripening',
        ],
      ),
      Crop(
        id: 'v15',
        name: 'Muskmelon (Kharbooj)',
        scientificName: 'Cucumis melo',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Melon_cantaloupe.jpg/800px-Melon_cantaloupe.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 60),
        growthStages: [
          'Germination',
          'Vine Development',
          'Flowering',
          'Fruit Set',
          'Ripening',
        ],
      ),
      Crop(
        id: 'v16',
        name: 'Garlic',
        scientificName: 'Allium sativum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Allium_sativum_Woodwill_1793.jpg/800px-Allium_sativum_Woodwill_1793.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 60),
        growthStages: [
          'Planting',
          'Vegetative',
          'Bulb Initiation',
          'Bulb Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'v17',
        name: 'Spinach (Palak)',
        scientificName: 'Spinacia oleracea',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Spinacia_oleracea_Spinach_10240px.jpg/800px-Spinacia_oleracea_Spinach_10240px.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 60),
        growthStages: ['Germination', 'Vegetative', 'Harvest'],
      ),
      Crop(
        id: 'v18',
        name: 'Fenugreek (Methi)',
        scientificName: 'Trigonella foenum-graecum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Koeh-060.jpg/640px-Koeh-060.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 20, p: 40, k: 20),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'v19',
        name: 'Carrot',
        scientificName: 'Daucus carota',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Vegetable-Carrot-Bundle-wStalks.jpg/800px-Vegetable-Carrot-Bundle-wStalks.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 60),
        growthStages: [
          'Germination',
          'Vegetative',
          'Root Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'v20',
        name: 'Radish (Mooli)',
        scientificName: 'Raphanus sativus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Radish-andi-3.jpg/800px-Radish-andi-3.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 50, p: 30, k: 40),
        growthStages: [
          'Germination',
          'Vegetative',
          'Root Swelling',
          'Maturity',
        ],
      ),

      // ── FRUITS ────────────────────────────────────────────
      Crop(
        id: 'f01',
        name: 'Mango',
        scientificName: 'Mangifera indica',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Mango_Mangifera_indica.jpg/800px-Mango_Mangifera_indica.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 100),
        growthStages: [
          'Bud Break',
          'Flowering',
          'Fruit Set',
          'Fruit Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f02',
        name: 'Banana',
        scientificName: 'Musa paradisiaca',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/44/Banana_farm.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 200, p: 60, k: 300),
        growthStages: [
          'Planting',
          'Vegetative',
          'Bunch Emergence',
          'Bunch Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f03',
        name: 'Grapes',
        scientificName: 'Vitis vinifera',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/6/6c/Grapes_during_pigmentation_anthocyanins.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 100, p: 60, k: 120),
        growthStages: [
          'Bud Burst',
          'Flowering',
          'Fruit Set',
          'Berry Development',
          'Ripening',
        ],
      ),
      Crop(
        id: 'f04',
        name: 'Pomegranate',
        scientificName: 'Punica granatum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/3/30/Pomegranate_fruit_-_I.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 60),
        growthStages: [
          'Bud Differentiation',
          'Flowering',
          'Fruit Set',
          'Fruit Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f05',
        name: 'Orange (Nagpur)',
        scientificName: 'Citrus sinensis',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Orange-Whole-%26-Split.jpg/800px-Orange-Whole-%26-Split.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 80),
        growthStages: [
          'Flowering',
          'Fruit Set',
          'Fruit Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f06',
        name: 'Papaya',
        scientificName: 'Carica papaya',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/1/10/Papaya1.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 80),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Flowering',
          'Fruit Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 'f07',
        name: 'Guava',
        scientificName: 'Psidium guajava',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/3/30/Guava_ID.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 60),
        growthStages: [
          'Vegetative',
          'Flower Bud',
          'Flowering',
          'Fruit Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f08',
        name: 'Coconut',
        scientificName: 'Cocos nucifera',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/f/f2/Coconut_on_tree_02.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 120),
        growthStages: ['Seedling', 'Juvenile', 'Bearing', 'Full Production'],
      ),
      Crop(
        id: 'f09',
        name: 'Custard Apple (Sitaphal)',
        scientificName: 'Annona squamosa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/0/01/Custard_apple.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 60),
        growthStages: [
          'Vegetative',
          'Flowering',
          'Fruit Set',
          'Fruit Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f10',
        name: 'Lemon',
        scientificName: 'Citrus limon',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Lemon.jpg/800px-Lemon.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 80),
        growthStages: [
          'Vegetative',
          'Flowering',
          'Fruit Set',
          'Fruit Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f11',
        name: 'Strawberry',
        scientificName: 'Fragaria ananassa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/2/29/PerfectStrawberry.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 80),
        growthStages: [
          'Planting',
          'Vegetative',
          'Flowering',
          'Fruit Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 'f12',
        name: 'Fig (Anjeer)',
        scientificName: 'Ficus carica',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/c/cf/Ficus_carica_-_K%C3%B6hler%E2%80%93s_Medizinal-Pflanzen-054.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 60),
        growthStages: [
          'Vegetative',
          'Flowering',
          'Fruit Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f13',
        name: 'Sweet Lime (Mosambi)',
        scientificName: 'Citrus limetta',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Orange-Whole-%26-Split.jpg/1024px-Orange-Whole-%26-Split.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 80),
        growthStages: ['Flowering', 'Fruit Set', 'Development', 'Maturity'],
      ),
      Crop(
        id: 'f14',
        name: 'Jackfruit',
        scientificName: 'Artocarpus heterophyllus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/6/6e/Jackfruit_Bangladesh.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 60),
        growthStages: [
          'Vegetative',
          'Flowering',
          'Fruit Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f15',
        name: 'Sapodilla (Chiku)',
        scientificName: 'Manilkara zapota',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/95/Sapodilla_fruit.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 60),
        growthStages: [
          'Vegetative',
          'Flowering',
          'Fruit Development',
          'Maturity',
        ],
      ),

      // ── SPICES ────────────────────────────────────────────
      Crop(
        id: 's01',
        name: 'Turmeric (Haldi)',
        scientificName: 'Curcuma longa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/2/27/Curcuma_longa_roots.jpg',
        category: 'Spice',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 120),
        growthStages: [
          'Planting',
          'Shoot Emergence',
          'Vegetative',
          'Rhizome Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 's02',
        name: 'Ginger (Adrak)',
        scientificName: 'Zingiber officinale',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/44/Ginger_plant.jpg',
        category: 'Spice',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 120),
        growthStages: [
          'Planting',
          'Shoot Emergence',
          'Vegetative',
          'Rhizome Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 's03',
        name: 'Coriander (Dhaniya)',
        scientificName: 'Coriandrum sativum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/d/d8/Coriander_%28Coriandrum_sativum%29.jpg',
        category: 'Spice',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 30),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Seed Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 's04',
        name: 'Cumin (Jeera)',
        scientificName: 'Cuminum cyminum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/8/82/Cumin_on_white.jpg',
        category: 'Spice',
        nutrientRequirement: NPKRequirement(n: 40, p: 20, k: 20),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Seed Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 's05',
        name: 'Fennel (Saunf)',
        scientificName: 'Foeniculum vulgare',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/1/12/Fennel_seeds.jpg',
        category: 'Spice',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 30),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Seed Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 's06',
        name: 'Cardamom (Elaichi)',
        scientificName: 'Elettaria cardamomum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/a/a7/Elettaria_cardamomum2.jpg',
        category: 'Spice',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 60),
        growthStages: [
          'Planting',
          'Vegetative',
          'Flowering',
          'Capsule Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 's07',
        name: 'Pepper (Kali Mirch)',
        scientificName: 'Piper nigrum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/e/e3/Piper_nigrum_-_K%C3%B6hler%E2%80%93s_Medizinal-Pflanzen-107.jpg',
        category: 'Spice',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 80),
        growthStages: [
          'Planting',
          'Vegetative',
          'Flowering',
          'Berry Development',
          'Harvest',
        ],
      ),

      // ── PLANTATION CROPS ──────────────────────────────────
      Crop(
        id: 'p01',
        name: 'Tea',
        scientificName: 'Camellia sinensis',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/44/Tea_garden_in_Munnar.jpg',
        category: 'Plantation',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 50),
        growthStages: ['Planting', 'Nursery', 'Young', 'Mature', 'Plucking'],
      ),
      Crop(
        id: 'p02',
        name: 'Coffee',
        scientificName: 'Coffea arabica',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/c/cf/Coffee_beans_-_by_Abdulaziz_Almuzaini.jpg',
        category: 'Plantation',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 80),
        growthStages: [
          'Nursery',
          'Young Plantation',
          'Bearing',
          'Full Bearing',
        ],
      ),
      Crop(
        id: 'p03',
        name: 'Rubber',
        scientificName: 'Hevea brasiliensis',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/7/76/Hevea_brasiliensis8.jpg',
        category: 'Plantation',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 80),
        growthStages: ['Nursery', 'Immature', 'Mature', 'Tapping'],
      ),

      // ── TUBERS ────────────────────────────────────────────
      Crop(
        id: 't01',
        name: 'Sweet Potato',
        scientificName: 'Ipomoea batatas',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/5/58/Ipomoea_batatas_006.jpg',
        category: 'Tuber',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 100),
        growthStages: [
          'Planting',
          'Vegetative',
          'Tuber Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 't02',
        name: 'Tapioca (Cassava)',
        scientificName: 'Manihot esculenta',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/d/d5/Manihot_esculenta_-_K%C3%B6hler%E2%80%93s_Medizinal-Pflanzen-088.jpg',
        category: 'Tuber',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 80),
        growthStages: [
          'Planting',
          'Vegetative',
          'Tuber Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 't03',
        name: 'Colocasia (Arbi)',
        scientificName: 'Colocasia esculenta',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/6/6b/Colocasia_esculenta_leaf.jpg',
        category: 'Tuber',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 60),
        growthStages: [
          'Planting',
          'Vegetative',
          'Corm Development',
          'Maturity',
        ],
      ),

      // ── FODDER ────────────────────────────────────────────
      Crop(
        id: 'fd01',
        name: 'Lucerne (Alfalfa)',
        scientificName: 'Medicago sativa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Alfalfa_Medicago_sativa_Flowering.jpg/800px-Alfalfa_Medicago_sativa_Flowering.jpg',
        category: 'Fodder',
        nutrientRequirement: NPKRequirement(n: 20, p: 60, k: 40),
        growthStages: [
          'Germination',
          'Seedling',
          'Vegetative',
          'Flowering',
          'Cutting',
        ],
      ),
      Crop(
        id: 'fd02',
        name: 'Berseem Clover',
        scientificName: 'Trifolium alexandrinum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/7/74/Trifolium_alexandrinum_kz.jpg',
        category: 'Fodder',
        nutrientRequirement: NPKRequirement(n: 20, p: 40, k: 30),
        growthStages: ['Germination', 'Vegetative', 'Cutting'],
      ),
      Crop(
        id: 'fd03',
        name: 'Napier Grass',
        scientificName: 'Pennisetum purpureum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Napier_grass_%28Pennisetum_purpureum%29_-_geograph.org.uk_-_1148699.jpg/800px-Napier_grass_%28Pennisetum_purpureum%29_-_geograph.org.uk_-_1148699.jpg',
        category: 'Fodder',
        nutrientRequirement: NPKRequirement(n: 100, p: 40, k: 60),
        growthStages: ['Planting', 'Establishment', 'Vegetative', 'Cutting'],
      ),

      // ── FLOWERS ───────────────────────────────────────────
      Crop(
        id: 'fl01',
        name: 'Marigold',
        scientificName: 'Tagetes erecta',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/0/0e/Marigold18.jpg',
        category: 'Flower',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 40),
        growthStages: ['Seedling', 'Vegetative', 'Bud', 'Flowering', 'Harvest'],
      ),
      Crop(
        id: 'fl02',
        name: 'Rose',
        scientificName: 'Rosa hybrida',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Rosa_rugosa_1_Luc_Viatour.jpg/800px-Rosa_rugosa_1_Luc_Viatour.jpg',
        category: 'Flower',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 60),
        growthStages: [
          'Planting',
          'Establishment',
          'Vegetative',
          'Flowering',
          'Harvest',
        ],
      ),
      Crop(
        id: 'fl03',
        name: 'Jasmine (Mogra)',
        scientificName: 'Jasminum sambac',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/7/7f/Jasminum_sambac_%281%29.jpg',
        category: 'Flower',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 60),
        growthStages: [
          'Planting',
          'Establishment',
          'Vegetative',
          'Flowering',
          'Harvest',
        ],
      ),
      Crop(
        id: 'fl04',
        name: 'Chrysanthemum',
        scientificName: 'Chrysanthemum indicum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/d/d8/Chrysanthemum1.jpg',
        category: 'Flower',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 60),
        growthStages: [
          'Planting',
          'Vegetative',
          'Bud Initiation',
          'Flowering',
          'Harvest',
        ],
      ),
      Crop(
        id: 'fl05',
        name: 'Tuberose (Rajnigandha)',
        scientificName: 'Polianthes tuberosa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Polianthes_tuberosa_Hdh.jpg/800px-Polianthes_tuberosa_Hdh.jpg',
        category: 'Flower',
        nutrientRequirement: NPKRequirement(n: 80, p: 50, k: 60),
        growthStages: [
          'Planting',
          'Vegetative',
          'Spike Emergence',
          'Flowering',
          'Harvest',
        ],
      ),

      // ── ADDITIONAL VEGETABLES ─────────────────────────────
      Crop(
        id: 'v21',
        name: 'French Beans',
        scientificName: 'Phaseolus vulgaris',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/90/Cowpea.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 50, k: 40),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Pod Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v22',
        name: 'Peas (Matar)',
        scientificName: 'Pisum sativum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/a/a1/Peas_in_pods_-_Studio.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 20, p: 50, k: 40),
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Pod Fill',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v23',
        name: 'Beetroot',
        scientificName: 'Beta vulgaris',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/3/37/Beetroot.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 60),
        growthStages: [
          'Germination',
          'Vegetative',
          'Root Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'v24',
        name: 'Turnip (Shalgam)',
        scientificName: 'Brassica napus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/4a/Radish-andi-3.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 40),
        growthStages: [
          'Germination',
          'Vegetative',
          'Root Development',
          'Maturity',
        ],
      ),
      Crop(
        id: 'v25',
        name: 'Drumstick (Moringa)',
        scientificName: 'Moringa oleifera',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/e/e4/Moringa_oleifera_fruits.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 40),
        growthStages: [
          'Planting',
          'Vegetative',
          'Flowering',
          'Pod Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 'v26',
        name: 'Snake Gourd',
        scientificName: 'Trichosanthes cucumerina',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Trichosanthes_cucumerina_-_Snake_Gourd.jpg/800px-Trichosanthes_cucumerina_-_Snake_Gourd.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 50),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'v27',
        name: 'Sponge Gourd (Turai)',
        scientificName: 'Luffa cylindrica',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Luffa_cylindrica_Blanco1.63.jpg/800px-Luffa_cylindrica_Blanco1.63.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 50),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Harvest'],
      ),
      Crop(
        id: 'v28',
        name: 'Ridge Gourd (Torai)',
        scientificName: 'Luffa acutangula',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Ridged_Loofah_in_India.jpg/800px-Ridged_Loofah_in_India.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 50),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Harvest'],
      ),
      Crop(
        id: 'v29',
        name: 'Lettuce',
        scientificName: 'Lactuca sativa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/7/7e/Lettuce_x320.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 40),
        growthStages: ['Germination', 'Rosette', 'Heading', 'Harvest'],
      ),
      Crop(
        id: 'v30',
        name: 'Sweet Corn',
        scientificName: 'Zea mays saccharata',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Maize_ear_closeup.jpg/1200px-Maize_ear_closeup.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 120, p: 60, k: 60),
        growthStages: [
          'Seedling',
          'Vegetative',
          'Tasseling',
          'Silking',
          'Harvest',
        ],
      ),

      // ── ADDITIONAL FRUITS ─────────────────────────────────
      Crop(
        id: 'f16',
        name: 'Apple',
        scientificName: 'Malus domestica',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 60),
        growthStages: [
          'Bud Break',
          'Flowering',
          'Fruit Set',
          'Fruit Development',
          'Harvest',
        ],
      ),
      Crop(
        id: 'f17',
        name: 'Pineapple',
        scientificName: 'Ananas comosus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/c/cb/Pineapple_and_cross_section.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 150),
        growthStages: [
          'Planting',
          'Vegetative',
          'Flower Induction',
          'Fruiting',
          'Maturity',
        ],
      ),
      Crop(
        id: 'f18',
        name: 'Avocado',
        scientificName: 'Persea americana',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/1/1f/Avocado_halved.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 80),
        growthStages: [
          'Seedling',
          'Juvenile',
          'Flowering',
          'Fruit Development',
          'Maturity',
        ],
      ),

      // ── MEDICINAL ─────────────────────────────────────────
      Crop(
        id: 'm01',
        name: 'Aloe Vera',
        scientificName: 'Aloe barbadensis',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/4b/Aloe_vera_flower_inset.png',
        category: 'Medicinal',
        nutrientRequirement: NPKRequirement(n: 40, p: 20, k: 40),
        growthStages: ['Planting', 'Establishment', 'Vegetative', 'Harvest'],
      ),
      Crop(
        id: 'm02',
        name: 'Stevia',
        scientificName: 'Stevia rebaudiana',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/d/d8/Stevia_rebaudiana.JPG',
        category: 'Medicinal',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 40),
        growthStages: ['Planting', 'Vegetative', 'Flowering', 'Harvest'],
      ),
      Crop(
        id: 'm03',
        name: 'Ashwagandha',
        scientificName: 'Withania somnifera',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Withania_somnifera.jpg/800px-Withania_somnifera.jpg',
        category: 'Medicinal',
        nutrientRequirement: NPKRequirement(n: 40, p: 20, k: 30),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
    ];
  }
}
