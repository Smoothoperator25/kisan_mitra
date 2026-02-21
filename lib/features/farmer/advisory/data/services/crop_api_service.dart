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
            'https://media.istockphoto.com/id/187251869/photo/rice-crop.jpg?s=612x612&w=0&k=20&c=ATxHepv7IZ99NcNKkA7WyPsrsjorIubeV1uZbXboGag=',
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
            'https://images.presentationgo.com/2025/04/green-wheat-field-sunrise.jpg',
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
            'https://brightcrop.in/cdn/shop/files/250grams_ca3fdf56-e5b8-4e9c-87f1-5ac0af04f2c7.png?v=1711950290&width=1445',
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
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiPtIFnv8R1Vl1ib5EcQGhES_QbUrgPWo-jAK9G6qmAhnFt3p1MNy1m-xo6Kz3wK93pIRx3bAB6jHPVkyPvAhWMkfgvqK1x4Kd3xrJEw&s=10',
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
            'https://i0.wp.com/afrimash.com/wp-content/uploads/2024/05/maize-prefered.jpg?ssl=1',
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
            'https://naturallyyours.in/cdn/shop/articles/ragi1.jpg?v=1659348826',
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
            'https://upload.wikimedia.org/wikipedia/commons/2/20/Barley_%28Hordeum_vulgare%29_-_United_States_National_Arboretum_-_24_May_2009.jpg',
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
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Avena_sativa_002.JPG/960px-Avena_sativa_002.JPG',
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
            'https://mybageecha.com/cdn/shop/products/Toor-Cajanus_cajan_1024x.jpg?v=1571438538',
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
            'https://www.epicgardening.com/wp-content/uploads/2021/10/A-close-up-shot-of-several-pods-of-legumes-alongside-their-leaves-showcasing-the-mung-bean.jpg',
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
            'https://kasturiudyavara.in/wp-content/uploads/2021/07/adfeeb1e-3af6-4e74-8019-26f8bb6035db.jpg',
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
            'https://www.agrifarming.in/wp-content/uploads/Guide-to-Chickpea-Bengal-GramChana-Farming-1.jpg',
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
            'https://nationalgauravaward.org/wp-content/uploads/2020/12/Red-Lentils1.jpg',
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
            'https://5.imimg.com/data5/WN/EF/SL/SELLER-13256592/cowpea-lobia-thattaipayuru-karamani.jpg',
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
            'https://img-cdn.publive.online/fit-in/1200x675/30-stades/media/media_files/2026/01/03/kulthi-dal-superfood-lead-30stades-2026-01-03-00-00-06.jpg',
        category: 'Legume',
        nutrientRequirement: NPKRequirement(n: 20, p: 40, k: 20),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'l08',
        name: 'Soybean',
        scientificName: 'Glycine max',
        imageUrl:
            'https://www.news-medical.net/images/news/ImageForNews_745986_16823072833517897.jpg',
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
            'https://www.protectourlivelihood.in/wp-content/uploads/2025/04/Image-Groundnut.jpg',
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
            'https://www.gardendesign.com/pictures/images/675x529Max/site_3/ring-of-fire-sunflower-bicolor-sunflower-all-america-selections_12080.jpg',
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
            'https://media.assettype.com/english-sentinelassam%2Fimport%2Fh-upload%2F2023%2F02%2F12%2F438138-mustard.webp?w=1200&ar=40%3A21&auto=format%2Ccompress&ogImage=true&mode=crop&enlarge=true&overlay=false&overlay_position=bottom&overlay_width=100',
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
            'https://www.chandigarhayurvedcentre.com/wp-content/uploads/2016/03/til.jpg',
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
            'https://5.imimg.com/data5/SELLER/Default/2022/9/SI/ZQ/OT/139751067/flax-seeds-linseeds.jpg',
        category: 'Oilseed',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 30),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'o06',
        name: 'Castor',
        scientificName: 'Ricinus communis',
        imageUrl:
            'https://www.shutterstock.com/image-photo/organic-ricinus-communis-oil-castor-600nw-2600935963.jpg',
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
            'https://www.apnikheti.com/upload/crops/33idea99safflower.jpg',
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
            'https://img.jagranjosh.com/1812021/iStock-589121090.webp',
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
            'https://www.mahagro.com/cdn/shop/articles/iStock_000063947343_Medium_4e1c882b-faf0-4487-b45b-c2b557d32442.jpg?v=1541408129&width=1100',
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
            'https://matixgroup.com/wp-content/uploads/2025/03/jute-location-1024x902.png',
        category: 'Fiber',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 40),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'com04',
        name: 'Tobacco',
        scientificName: 'Nicotiana tabacum',
        imageUrl:
            'https://eos.com/wp-content/uploads/2024/10/growing-tobacco-main.jpg',
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
            'https://cdn.britannica.com/16/187216-050-CB57A09B/tomatoes-tomato-plant-Fruit-vegetable.jpg?w=400&h=300&c=crop',
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
            'https://m.media-amazon.com/images/I/41uWBT2Hw-L._AC_UF1000,1000_QL80_.jpg',
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
            'https://cdn.mos.cms.futurecdn.net/v2/t:0,l:420,cw:1080,ch:1080,q:80,w:1080/iC7HBvohbJqExqvbKcV3pP.jpg',
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
            'https://static.wixstatic.com/media/5f1a7b_5f9cec1922cf45acb1884aa8e4958856~mv2.jpg/v1/fill/w_640,h_326,al_c,q_80,usm_0.66_1.00_0.01,enc_auto/5f1a7b_5f9cec1922cf45acb1884aa8e4958856~mv2.jpg',
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
            'https://m.media-amazon.com/images/I/51WrXUG8qLL._AC_UF1000,1000_QL80_.jpg',
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
            'https://cdn.mos.cms.futurecdn.net/fxTMUKDnKRGq2twv7iecH4.jpg',
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
            'https://www.freshpoint.com/wp-content/uploads/2019/03/freshpoint-produce-101-peppers-4.jpg',
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
            'https://www.thespruce.com/thmb/3xv-bplva31jK5D9fYL0_5c9UB0=/4696x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-to-grow-cauliflower-1403494-hero-76cf5f524a564adabb1ac6adfa311482.jpg',
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
            'https://images.squarespace-cdn.com/content/v1/60d5fe5c9e25003cd4b3b2ed/1634316438635-27FNWQSMMPRHWXB0MLGJ/green-cabbage-envato.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 100, p: 60, k: 60),
        growthStages: ['Seedling', 'Vegetative', 'Head Formation', 'Maturity'],
      ),
      Crop(
        id: 'v10',
        name: 'Cucumber',
        scientificName: 'Cucumis sativus',
        imageUrl:
            'https://hgtvhome.sndimg.com/content/dam/images/hgtv/fullset/2020/2/16/0/shutterstock_316149275.jpg.rend.hgtvcom.1280.960.85.suffix/1581877377601.webp',
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
            'https://drvaidji.com/cdn/shop/articles/Bitter_Melon_1024x1024_37ab9838-93f6-4c88-83b4-508443174b78.jpg?v=1699514225',
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
            'https://gardeningcentre.in/cdn/shop/files/lauki.jpg?v=1707578281',
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
            'https://m.media-amazon.com/images/I/61xFCOu6W5L._AC_UF1000,1000_QL80_.jpg',
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
            'https://hips.hearstapps.com/hmg-prod/images/fresh-ripe-watermelon-slices-on-wooden-table-royalty-free-image-1684966820.jpg?crop=0.88973xw:1xh;center,top&resize=1200:*',
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
            'https://image.myupchar.com/1957/original/muskmelon-seeds-benefits-in-hindi.jpg',
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
            'https://connect.healthkart.com/wp-content/uploads/2016/12/Banner-2021-05-05T174631.491.jpg',
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
            'https://nurserynisarga.in/wp-content/uploads/2021/10/elianna-friedman-4jpNPu7IW8k-unsplash.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 60),
        growthStages: ['Germination', 'Vegetative', 'Harvest'],
      ),
      Crop(
        id: 'v18',
        name: 'Fenugreek (Methi)',
        scientificName: 'Trigonella foenum-graecum',
        imageUrl:
            'https://beejwala.com/cdn/shop/products/fenugreek-4_compressed.jpg?v=1653821518',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 20, p: 40, k: 20),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'v19',
        name: 'Carrot',
        scientificName: 'Daucus carota',
        imageUrl:
            'https://www.trustbasket.com/cdn/shop/articles/Carrot.jpg?v=1688378789',
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
            'https://freshfarmse.com/wp-content/uploads/2025/09/360_F_221710872_T4XcHOJslwykFteHlgPBf8PXglkAwiyG.jpg',
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
            'https://www.biovie.fr/img/cms/histoire-origine-mangue.png',
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
            'https://zamaorganics.com/cdn/shop/files/banana1000_x_1000_px_1.png?v=1752738968',
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
            'https://www.apnikheti.com/upload/crops/1850idea99grapes.jpg',
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
            'https://plantsguru.com/cdn/shop/files/Ripe-Pomegranate-Fruit-on-Tree-Branch.jpg?v=1755687567',
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
            'https://m.media-amazon.com/images/I/51qFSdheDPL._AC_UF1000,1000_QL80_.jpg',
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
            'https://andamangreengrocers.com/wp-content/uploads/2021/12/1639840955890-e1639848809306.jpg',
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
            'https://www.health.com/thmb/XlWTD8TZF5574DVtMEfD-XSj5Lg=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Guava-15d1050d22034909bfca038ef1f8aaa2.jpg',
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
            'https://images.squarespace-cdn.com/content/v1/5c1074accc8fed6a4251da8f/1632825358284-7LGGMHZO98Q9L3FWUSKC/Coconut+Tree',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 120),
        growthStages: ['Seedling', 'Juvenile', 'Bearing', 'Full Production'],
      ),
      Crop(
        id: 'f09',
        name: 'Custard Apple (Sitaphal)',
        scientificName: 'Annona squamosa',
        imageUrl:
            'https://m.media-amazon.com/images/I/71tsufOwH5L._AC_UF1000,1000_QL80_.jpg',
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
            'https://cdn.britannica.com/84/188484-050-F27B0049/lemons-tree.jpg',
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
            'https://im.pluckk.in/unsafe/1920x0/uploads/30300-2.png',
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
            'https://www.aishcart.in/4303/figs-anjeer-fruit-1kg.jpg',
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
            'https://bhoomifresh.com/image/cache/catalog/Fruits/mosambis-600x367.jpg',
        category: 'Fruit',
        nutrientRequirement: NPKRequirement(n: 80, p: 40, k: 80),
        growthStages: ['Flowering', 'Fruit Set', 'Development', 'Maturity'],
      ),
      Crop(
        id: 'f14',
        name: 'Jackfruit',
        scientificName: 'Artocarpus heterophyllus',
        imageUrl:
            'https://images.everydayhealth.com/images/diet-nutrition/jackfruit-101-1440x810.jpg?w=508',
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
            'https://nurserylive.com/cdn/shop/products/nurserylive-chikoo-sapota-chiku-fruit-grafted-plant.jpg?v=1634215991',
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
            'https://dhanipurespices.com/wp-content/uploads/2022/10/Turmeric-Powder-and-Whole.jpeg',
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
            'https://m.media-amazon.com/images/I/71cKdUVK6cL._AC_UF1000,1000_QL80_.jpg',
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
            'https://m.media-amazon.com/images/I/61x9Zv3gI7L._AC_UF1000,1000_QL80_.jpg',
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
            'https://www.greendna.in/cdn/shop/products/cumin1_1000x.jpg?v=1561041488',
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
            'https://www.puremart.in/images/products/thumbnails/533-fennel-saunf-500gms-1746611849.jpeg',
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
            'https://www.agrifarming.in/wp-content/uploads/Ultimate-Guide-to-Cardamom-Elaichi-Farming-1.jpg',
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
            'https://m.media-amazon.com/images/I/61bv6tKoW8L._AC_UF894,1000_QL80_.jpg',
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
            'https://m.media-amazon.com/images/I/71Pw4pgd69L.jpg',
        category: 'Plantation',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 50),
        growthStages: ['Planting', 'Nursery', 'Young', 'Mature', 'Plucking'],
      ),
      Crop(
        id: 'p02',
        name: 'Coffee',
        scientificName: 'Coffea arabica',
        imageUrl:
            'https://www.aboutcoffee.org/wp-content/uploads/2024/10/ripe-coffee-cherries-on-branch-of-coffee-tree-1024x576.jpg',
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
            'https://www.rainforest-alliance.org/wp-content/uploads/2021/06/rubber-tree-tapping-square-1.jpg.optimal.jpg',
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
            'https://foodcare.in/cdn/shop/files/sweetpotato.jpg?v=1768271500',
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
            'https://www.shutterstock.com/image-photo/tapioca-plants-cassava-closeup-useful-600w-83105608.jpg',
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
            'https://www.jiomart.com/images/product/original/590004128/arbi-colocasia-small-250-g-product-images-o590004128-p590004128-0-202408070949.jpg?im=Resize=(1000,1000)',
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
            'https://nurserylive.com/cdn/shop/products/nurserylive-seeds-alfalfa-lucerne-seeds_300x@2x.jpg?v=1634212997',
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
            'https://growhoss.com/cdn/shop/products/frosty-berseem-clover_460x@2x.jpg?v=1691781056',
        category: 'Fodder',
        nutrientRequirement: NPKRequirement(n: 20, p: 40, k: 30),
        growthStages: ['Germination', 'Vegetative', 'Cutting'],
      ),
      Crop(
        id: 'fd03',
        name: 'Napier Grass',
        scientificName: 'Pennisetum purpureum',
        imageUrl:
            'https://khetkidawai.com/wp-content/uploads/2023/09/super-napier-grass-1.webp',
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
            'https://gardenerspath.com/wp-content/uploads/2024/03/How-to-Grow-Marigolds-Feature.jpg',
        category: 'Flower',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 40),
        growthStages: ['Seedling', 'Vegetative', 'Bud', 'Flowering', 'Harvest'],
      ),
      Crop(
        id: 'fl02',
        name: 'Rose',
        scientificName: 'Rosa hybrida',
        imageUrl:
            'https://i.pinimg.com/736x/7f/f3/3f/7ff33fae1896f12a779a5640f7c8d232.jpg',
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
            'https://m.media-amazon.com/images/I/61xreWtQL6L._AC_UF1000,1000_QL80_.jpg',
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
            'https://www.padmamnursery.com/cdn/shop/files/growing-chrysanthemum-02-_1.jpg?v=1728318433',
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
            'https://www.hugaplant.com/cdn/shop/files/MAIN_5cf6c879-c583-49b1-87fd-225d90c04bfc.png?v=1694176650',
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
            'https://creativefarmer.in/cdn/shop/products/601.png?v=1616235759',
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
            'https://plantogallery.com/cdn/shop/files/greenpea.jpg?v=1754119747',
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
            'https://www.seedparade.co.uk/news/wp-content/uploads/2023/08/beetroot-boltardy.jpg',
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
            'https://www.trustbasket.com/cdn/shop/articles/Turnip.webp?v=1679656480',
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
            'https://organicbazar.net/cdn/shop/products/Untitled-design-2022-06-05T111342.081.jpg?v=1771571732&width=1445',
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
            'https://satvafarm.com/cdn/shop/files/snakegourd_65a7734d-87eb-4a02-a8fd-a6946e1f0535.jpg?v=1737359125',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 50),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
      Crop(
        id: 'v27',
        name: 'Sponge Gourd (Turai)',
        scientificName: 'Luffa cylindrica',
        imageUrl:
            'https://m.media-amazon.com/images/I/51+-z6eG+BL._AC_UF1000,1000_QL80_.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 50),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Harvest'],
      ),
      Crop(
        id: 'v28',
        name: 'Ridge Gourd (Torai)',
        scientificName: 'Luffa acutangula',
        imageUrl:
            'https://m.media-amazon.com/images/I/61N65aFfSPL._AC_UF1000,1000_QL80_.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 50),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Harvest'],
      ),
      Crop(
        id: 'v29',
        name: 'Lettuce',
        scientificName: 'Lactuca sativa',
        imageUrl:
            'https://media.newyorker.com/photos/5b6b08d3a676470b4ea9b91f/1:1/w_1748,h_1748,c_limit/Rosner-Lettuce.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 60, p: 40, k: 40),
        growthStages: ['Germination', 'Rosette', 'Heading', 'Harvest'],
      ),
      Crop(
        id: 'v30',
        name: 'Sweet Corn',
        scientificName: 'Zea mays saccharata',
        imageUrl:
            'https://lh5.googleusercontent.com/proxy/GbS8Sytqrirx0cVt9MZ0HQSVIGsQzbMk_XlBZf4flasKXCroXph2WEwbwaL299pz9KeKdA4nT4Ns1tpZSNzTdYH3pGiJubqiQTlqNcYRO5zuvK3pK3DA8q09_nnvl1oqyd0Ayn1N_lVTD0PvM1fn1pEsxAeNJQ',
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
            'https://cdn.britannica.com/72/170772-050-D52BF8C2/Avocado-fruits.jpg',
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
            'https://thealtitudestore.com/cdn/shop/files/Aloe-Vera-Aloe-barbadensis-_miller_-2-Gallon_7_1080x_ebe5e737-c509-4af5-bd01-3893727bbfbb.webp?v=1748240155',
        category: 'Medicinal',
        nutrientRequirement: NPKRequirement(n: 40, p: 20, k: 40),
        growthStages: ['Planting', 'Establishment', 'Vegetative', 'Harvest'],
      ),
      Crop(
        id: 'm02',
        name: 'Stevia',
        scientificName: 'Stevia rebaudiana',
        imageUrl:
            'https://www.apnikheti.com/upload/crops/7365idea99STEVIA.jpg',
        category: 'Medicinal',
        nutrientRequirement: NPKRequirement(n: 60, p: 30, k: 40),
        growthStages: ['Planting', 'Vegetative', 'Flowering', 'Harvest'],
      ),
      Crop(
        id: 'm03',
        name: 'Ashwagandha',
        scientificName: 'Withania somnifera',
        imageUrl:
            'https://www.dhanvantariarogya.com/uploads/2/2025-07/ashwagandha_1.jpg',
        category: 'Medicinal',
        nutrientRequirement: NPKRequirement(n: 40, p: 20, k: 30),
        growthStages: ['Germination', 'Vegetative', 'Flowering', 'Maturity'],
      ),
    ];
  }
}
