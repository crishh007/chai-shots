const Series = require("../models/Series");

// Create Series
exports.createSeries = async (req, res) => {
  try {

    const { title, description, category } = req.body;

    const series = new Series({
      title,
      description,
      category
    });

    await series.save();

    res.json({
      message: "Series created successfully",
      series
    });

  } catch (error) {
    res.status(500).json({
      message: "Error creating series"
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