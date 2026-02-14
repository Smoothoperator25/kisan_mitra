class FertilizerImageService {
  static const Map<String, String> _images = {
    'Triple Super Phosphate':
        'https://5.imimg.com/data5/SELLER/Default/2023/1/YI/YI/VO/34940237/triple-super-phosphate-fertilizer.jpg',
    'Muriate of Potash':
        'https://5.imimg.com/data5/SELLER/Default/2022/9/KM/KM/PO/47285647/muriate-of-potash-fertilizer.jpg',
    'Urea':
        'https://5.imimg.com/data5/SELLER/Default/2023/4/302830846/NE/QF/XB/34940237/urea-fertilizer-46-0-0.jpg',
    'DAP':
        'https://5.imimg.com/data5/SELLER/Default/2023/1/JO/JO/HE/34940237/dap-fertilizer.jpg',
    'SSP':
        'https://5.imimg.com/data5/SELLER/Default/2022/12/UI/UI/XQ/34940237/single-super-phosphate-fertilizer.jpg',
  };

  static String getImageUrl(String fertilizerName) {
    // Check for partial matches or exact matches
    for (var entry in _images.entries) {
      if (fertilizerName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    // Default placeholder
    return 'https://cdn-icons-png.flaticon.com/512/2674/2674067.png';
  }
}
