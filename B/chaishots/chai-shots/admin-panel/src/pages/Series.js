import React, { useEffect, useState } from "react";
import API from "../services/api";
import {
  TextField,
  Button,
  Table,
  TableRow,
  TableCell,
  TableHead,
  TableBody,
  Paper,
  Box,
  Typography,
  IconButton,
  Snackbar,
  Alert,
  Checkbox,
  FormControlLabel
} from "@mui/material";
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutline';
import VisibilityIcon from '@mui/icons-material/Visibility';
import { Link } from "react-router-dom";

function Series() {
  const [series, setSeries] = useState([]);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [thumbnail, setThumbnail] = useState(null);
  const [video, setVideo] = useState(null);
  const [isTrending, setIsTrending] = useState(false);
  const [isNew, setIsNew] = useState(false);
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState({ open: false, message: "", severity: "success" });

  const handleCloseToast = () => setToast({ ...toast, open: false });
  const showToast = (message, severity = "success") => setToast({ open: true, message, severity });

  const fetchSeries = async () => {
    try {
      const res = await API.get("/series/");
      setSeries(res.data);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    fetchSeries();
  }, []);

  const addSeries = async () => {
    if (!title) {
      alert("Please enter a title");
      return;
    }

    setLoading(true);
    try {
      const formData = new FormData();
      formData.append("title", title);
      if (description) {
        formData.append("description", description);
      }
      if (thumbnail) {
        formData.append("thumbnail", thumbnail);
      }
      if (video) {
        formData.append("video", video);
      }
      formData.append("isTrending", isTrending);
      formData.append("isNew", isNew);

      await API.post("/series/create", formData);
      fetchSeries();
      setTitle(""); // clear input
      setDescription(""); // clear description
      setThumbnail(null); // clear thumbnail
      setVideo(null); // clear video
      setIsTrending(false); // reset state
      setIsNew(false); // reset state
      showToast("Series added successfully", "success");
    } catch (err) {
      console.error(err);
      showToast("Error adding series", "error");
    } finally {
      setLoading(false);
    }
  };

  const deleteSeries = async (id) => {
    if (window.confirm("Are you sure you want to delete this series?")) {
      try {
        await API.delete(`/series/${id}`);
        fetchSeries();
        showToast("Deleted successfully", "success");
      } catch (err) {
        console.error(err);
        showToast("Error deleting series", "error");
      }
    }
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 3 }}>
        Series Management
      </Typography>

      <Paper sx={{ p: 3, mb: 4, display: 'flex', flexDirection: 'column', gap: 2, borderRadius: 2 }}>
        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center', width: '100%' }}>
          <TextField
            label="New Series Title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            size="medium"
            sx={{ flexGrow: 1 }}
          />
          <TextField
            label="Description (Optional)"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            size="medium"
            sx={{ flexGrow: 2 }}
          />
        </Box>
        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
          <FormControlLabel
            control={<Checkbox checked={isTrending} onChange={(e) => setIsTrending(e.target.checked)} />}
            label="Trending"
          />
          <FormControlLabel
            control={<Checkbox checked={isNew} onChange={(e) => setIsNew(e.target.checked)} />}
            label="New Release"
          />
        </Box>
        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center', alignSelf: 'flex-start' }}>
          <Button
            variant="outlined"
            component="label"
          >
            Upload Thumbnail
            <input
              type="file"
              hidden
              accept="image/*"
              onChange={(e) => setThumbnail(e.target.files[0])}
            />
          </Button>
          {thumbnail && (
            <Typography variant="caption" sx={{ maxWidth: 100, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {thumbnail.name}
            </Typography>
          )}
          <Button
            variant="outlined"
            component="label"
          >
            Upload Trailer
            <input
              type="file"
              hidden
              accept="video/*"
              onChange={(e) => setVideo(e.target.files[0])}
            />
          </Button>
          {video && (
            <Typography variant="caption" sx={{ maxWidth: 100, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {video.name}
            </Typography>
          )}
          <Button 
            variant="contained" 
            onClick={addSeries}
            disabled={!title.trim() || loading}
            startIcon={<AddCircleOutlineIcon />}
            sx={{ py: 1.5, px: 3, fontWeight: 'bold' }}
          >
            {loading ? "Adding..." : "Add Series"}
          </Button>
        </Box>
      </Paper>

      {series && series.length > 0 ? (
        <Paper sx={{ borderRadius: 2, overflow: 'hidden' }}>
          <Table>
            <TableHead sx={{ bgcolor: 'primary.main' }}>
              <TableRow>
                <TableCell sx={{ color: 'primary.contrastText', fontWeight: 'bold' }}>Thumbnail</TableCell>
                <TableCell sx={{ color: 'primary.contrastText', fontWeight: 'bold' }}>Title</TableCell>
                <TableCell sx={{ color: 'primary.contrastText', fontWeight: 'bold' }}>Description</TableCell>
                <TableCell align="right" sx={{ color: 'primary.contrastText', fontWeight: 'bold' }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {series.map((s, index) => (
                <TableRow key={s._id} sx={{ bgcolor: index % 2 === 0 ? 'background.default' : 'background.paper' }}>
                  <TableCell>
                    {s.thumbnail ? (
                      <img src={s.thumbnail} alt={s.title} style={{ width: 60, height: 'auto', borderRadius: 4, objectFit: 'cover' }} />
                    ) : (
                      <Typography variant="caption" color="text.secondary">No Image</Typography>
                    )}
                  </TableCell>
                  <TableCell sx={{ fontWeight: 'medium' }}>{s.title}</TableCell>
                  <TableCell>
                    <Typography variant="body2" color="text.secondary" sx={{ maxWidth: 300, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {s.description || "No description"}
                    </Typography>
                  </TableCell>
                  <TableCell align="right">
                    <IconButton color="primary" component={Link} to={`/series/${s._id}/episodes`} title="View Episodes">
                      <VisibilityIcon />
                    </IconButton>
                    <IconButton color="error" onClick={() => deleteSeries(s._id)} title="Delete Series">
                      <DeleteOutlineIcon />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      ) : (
        <Paper sx={{ p: 5, textAlign: 'center', borderRadius: 2 }}>
          <Typography variant="h6" color="text.secondary">
            No series available. Create one.
          </Typography>
        </Paper>
      )}

      <Snackbar open={toast.open} autoHideDuration={4000} onClose={handleCloseToast} anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}>
        <Alert onClose={handleCloseToast} severity={toast.severity} sx={{ width: '100%' }}>
          {toast.message}
        </Alert>
      </Snackbar>
    </Box>
  );
}

export default Series;
