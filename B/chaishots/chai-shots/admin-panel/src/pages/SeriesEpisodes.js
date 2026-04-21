import React, { useEffect, useState } from "react";
import { useParams, Link } from "react-router-dom";
import API from "../services/api";
import {
  Box,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Button,
  IconButton,
  Snackbar,
  Alert
} from "@mui/material";
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import AddIcon from '@mui/icons-material/Add';

function SeriesEpisodes() {
  const { id } = useParams();
  const [episodes, setEpisodes] = useState([]);
  const [toast, setToast] = useState({ open: false, message: "", severity: "success" });

  const handleCloseToast = () => setToast({ ...toast, open: false });
  const showToast = (message, severity = "success") => setToast({ open: true, message, severity });

  useEffect(() => {
    fetchEpisodes();
  }, [id]);

  const fetchEpisodes = async () => {
    try {
      const res = await API.get(`/episodes/series/${id}`);
      setEpisodes(res.data);
    } catch (err) {
      console.error(err);
    }
  };

  const deleteEpisode = async (episodeId) => {
    if (window.confirm("Are you sure you want to delete this episode?")) {
      try {
        await API.delete(`/episodes/${episodeId}`);
        fetchEpisodes();
        showToast("Episode deleted successfully", "success");
      } catch (err) {
        console.error(err);
        showToast("Error deleting episode", "error");
      }
    }
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
        <Button component={Link} to="/series" startIcon={<ArrowBackIcon />} sx={{ mr: 2, bgcolor: 'background.paper', boxShadow: 1 }}>
          Back to Series
        </Button>
        <Typography variant="h4" sx={{ fontWeight: 'bold', flexGrow: 1 }}>
          Series Episodes
        </Typography>
        <Button component={Link} to={`/upload?seriesId=${id}`} variant="contained" color="primary" startIcon={<AddIcon />} sx={{ fontWeight: 'bold' }}>
          Add Episode
        </Button>
      </Box>

      {episodes && episodes.length > 0 ? (
        <Paper sx={{ borderRadius: 2, overflow: 'hidden' }}>
          <Table>
            <TableHead sx={{ bgcolor: 'primary.main' }}>
              <TableRow>
                <TableCell sx={{ color: 'primary.contrastText', fontWeight: 'bold' }}>Title</TableCell>
                <TableCell sx={{ color: 'primary.contrastText', fontWeight: 'bold' }}>Video Link</TableCell>
                <TableCell align="right" sx={{ color: 'primary.contrastText', fontWeight: 'bold' }}>Uploaded At</TableCell>
                <TableCell align="right" sx={{ color: 'primary.contrastText', fontWeight: 'bold' }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {episodes.map((ep, index) => (
                <TableRow key={ep._id} sx={{ bgcolor: index % 2 === 0 ? 'background.default' : 'background.paper' }}>
                  <TableCell sx={{ fontWeight: 'medium' }}>{ep.title}</TableCell>
                  <TableCell>
                    <a href={ep.videoUrl} target="_blank" rel="noopener noreferrer" style={{ color: '#1976d2', textDecoration: 'none', fontWeight: 'bold' }}>
                      Watch Video
                    </a>
                  </TableCell>
                  <TableCell align="right">{new Date(ep.createdAt).toLocaleDateString()}</TableCell>
                  <TableCell align="right">
                    <IconButton color="error" onClick={() => deleteEpisode(ep._id)} title="Delete Episode">
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
            No episodes uploaded for this series yet.
          </Typography>
          <Button component={Link} to={`/upload?seriesId=${id}`} variant="contained" sx={{ mt: 2 }}>
            Upload Episode Now
          </Button>
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

export default SeriesEpisodes;
