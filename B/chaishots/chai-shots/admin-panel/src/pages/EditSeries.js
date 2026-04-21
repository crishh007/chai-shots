import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { updateSeries, getSeries } from "../services/api";
import Sidebar from "../components/Sidebar";
import { Box, Typography, TextField, Button, Paper } from "@mui/material";

function EditSeries() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState({
    title: "",
    description: "",
    posterUrl: "",
    language: "",
    freeEpisodesCount: 3
  });

  useEffect(() => {
    const fetchSingleSeries = async () => {
      const res = await getSeries();
      const seriesList = res.data.data;
      const target = seriesList.find((s) => s._id === id);
      if (target) {
        setForm(target);
      }
    };
    fetchSingleSeries();
  }, [id]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    await updateSeries(id, form);
    alert("Updated!");
    navigate("/series");
  };

  return (
    <Box sx={{ display: "flex" }}>
      <Sidebar />
      <Box sx={{ flexGrow: 1, p: 3 }}>
        <Typography variant="h4" gutterBottom>Edit Series</Typography>
        <Paper sx={{ p: 3, maxWidth: 600 }}>
          <form onSubmit={handleSubmit}>
            <TextField fullWidth margin="normal" label="Title" value={form.title} onChange={(e) => setForm({...form, title: e.target.value})} />
            <TextField fullWidth margin="normal" label="Description" value={form.description} onChange={(e) => setForm({...form, description: e.target.value})} multiline rows={3} />
            <TextField fullWidth margin="normal" label="Poster URL" value={form.posterUrl} onChange={(e) => setForm({...form, posterUrl: e.target.value})} />
            <TextField fullWidth margin="normal" label="Language" value={form.language} onChange={(e) => setForm({...form, language: e.target.value})} />
            <TextField fullWidth margin="normal" label="Free Episodes Count" type="number" value={form.freeEpisodesCount} onChange={(e) => setForm({...form, freeEpisodesCount: e.target.value})} />
            <Button variant="contained" color="primary" type="submit" sx={{ mt: 2 }}>Update</Button>
          </form>
        </Paper>
      </Box>
    </Box>
  );
}

export default EditSeries;
