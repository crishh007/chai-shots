import React, { useEffect, useState } from "react";
import API from "../services/api";
import { Box, Typography, Select, MenuItem, TextField, Button, InputLabel, FormControl, Paper, Checkbox, FormControlLabel } from "@mui/material";
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import MovieIcon from '@mui/icons-material/Movie';
import { useLocation } from "react-router-dom";

function UploadEpisode() {
  const location = useLocation();
  const queryParams = new URLSearchParams(location.search);
  let initialSeriesId = queryParams.get("seriesId");
  
  // Prevent string "undefined" from being set as the default seriesId
  if (initialSeriesId === "undefined") {
    initialSeriesId = "";
  }

  const [seriesList, setSeriesList] = useState([]);
  const [seriesId, setSeriesId] = useState(initialSeriesId || "");
  const [title, setTitle] = useState("");
  const [video, setVideo] = useState(null);
  const [isPremium, setIsPremium] = useState(false);
  const [isDiscover, setIsDiscover] = useState(false);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    API.get("/series/").then((res) => setSeriesList(res.data)).catch(console.error);
  }, []);

  const handleUpload = async () => {
    if (!title || !seriesId || !video) {
      alert("All fields required");
      return;
    }

    setUploading(true);
    try {
      const formData = new FormData();
      formData.append("video", video);
      formData.append("title", title);
      formData.append("seriesId", seriesId);
      formData.append("isPremium", isPremium);
      formData.append("isDiscover", String(isDiscover));

      // Single step: Upload video and create Episode entirely mapped in the backend
      await API.post("/episodes/upload", formData);

      alert("Episode uploaded successfully");
      setTitle("");
      setSeriesId("");
      setVideo(null);
      setIsPremium(false);
      setIsDiscover(false);
    } catch (err) {
      console.error(err);
      const errorMsg = err.response && err.response.data && err.response.data.message 
                        ? err.response.data.message 
                        : err.message;
      alert("Error occurred while uploading: " + errorMsg);
    } finally {
      setUploading(false);
    }
  };

  const isFormValid = seriesId && title.trim() !== "" && video;

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      <Box sx={{ width: '100%', maxWidth: 600 }}>
        <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 3 }}>
          Upload Episode
        </Typography>

        <Paper elevation={3} sx={{ p: 4, borderRadius: 2 }}>
          <FormControl fullWidth margin="normal">
            <InputLabel>Select Series</InputLabel>
            <Select
              value={seriesId}
              label="Select Series"
              onChange={(e) => setSeriesId(e.target.value)}
            >
              {seriesList && seriesList.length > 0 ? (
                seriesList.map((s) => (
                  <MenuItem value={s._id} key={s._id}>
                    {s.title}
                  </MenuItem>
                ))
              ) : (
                <MenuItem disabled value="">
                  No series available. Create one first.
                </MenuItem>
              )}
            </Select>
          </FormControl>

          <TextField
            fullWidth
            margin="normal"
            label="Episode Title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />

          <Box sx={{ mt: 3, mb: 4, display: 'flex', flexDirection: 'column', gap: 1 }}>
            <Button
              component="label"
              variant="outlined"
              startIcon={<MovieIcon />}
              sx={{ py: 1.5, borderStyle: 'dashed', borderWidth: 2 }}
            >
              {video ? video.name : "Choose Video File"}
              <input
                type="file"
                accept="video/*"
                hidden
                onChange={(e) => setVideo(e.target.files[0])}
              />
            </Button>
            {video && (
              <Typography variant="caption" color="success.main" sx={{ textAlign: 'center' }}>
                Selected: {video.name}
              </Typography>
            )}
          </Box>

          <FormControlLabel
            control={
              <Checkbox
                checked={isDiscover}
                onChange={(e) => setIsDiscover(e.target.checked)}
              />
            }
            label="Show in Discover (Trailer)"
          />

          <FormControlLabel
            control={
              <Checkbox
                checked={isPremium}
                onChange={(e) => setIsPremium(e.target.checked)}
              />
            }
            label="Premium Episode (Locked for non-subscribers)"
            sx={{ mb: 3 }}
          />

          <Button 
            fullWidth
            variant="contained" 
            size="large"
            startIcon={uploading ? null : <CloudUploadIcon />}
            onClick={handleUpload} 
            disabled={!isFormValid || uploading}
            sx={{ py: 1.5, fontWeight: 'bold' }}
          >
            {uploading ? "Uploading..." : "Upload Episode"}
          </Button>
        </Paper>
      </Box>
    </Box>
  );
}

export default UploadEpisode;
