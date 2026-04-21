const Series = require("../models/Series");

// Create Series
exports.createSeries = async (req, res) => {
  try {
    const { title, description, category, isTrending, isNew } = req.body;
    
    // Handle files from multer
    const thumbnail = req.files && req.files['thumbnail'] ? req.files['thumbnail'][0].path : null;
    const videoUrl = req.files && req.files['video'] ? req.files['video'][0].path : null;

    const series = new Series({
      title,
      description,
      category,
      thumbnail,
      videoUrl,
      isTrending: isTrending === 'true' || isTrending === true,
      isNewRelease: isNew === 'true' || isNew === true // Map frontend 'isNew' to backend 'isNewRelease'
    });

    await series.save();

    res.json({
      message: "Series created successfully",
      series
    });

  } catch (error) {
    console.error("Error creating series:", error);
    res.status(500).json({
      message: "Error creating series",
      error: error.message
    });
  }
};

// Get all series
exports.getSeries = async (req, res) => {
  try {
    const series = await Series.find();
    res.json(series);
  } catch (error) {
    res.status(500).json({
      message: "Error fetching series"
    });
  }
};

// Delete series
exports.deleteSeries = async (req, res) => {
  try {
    const { id } = req.params;
    await Series.findByIdAndDelete(id);
    res.json({ message: "Series deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting series" });
  }
};