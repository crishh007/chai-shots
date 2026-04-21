const multer = require("multer");
const { CloudinaryStorage } = require("multer-storage-cloudinary");
const cloudinary = require("../config/cloudinary");

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: async (req, file) => {
    // Dynamically set resource_type based on field name or mimetype
    let resourceType = "auto";
    if (file.fieldname === 'video') resourceType = "video";
    if (file.fieldname === 'thumbnail') resourceType = "image";
    const params = {
      folder: "chai-ott",
      resource_type: resourceType
    };

    if (resourceType === "video") {
      params.format = "mp4";
      // Force it to encode as h264 to fix the black screen bug on web browsers
      params.video_codec = "h264";
    }

    return params;
  }
});

const upload = multer({ storage });

module.exports = upload;