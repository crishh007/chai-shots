import React, { useState } from "react";
import { createSeries } from "../services/api";
import Sidebar from "../components/Sidebar";
import { Box, Typography, TextField, Button, Paper } from "@mui/material";

function CreateSeries() {
  const [form, setForm] = useState({
    title: "",
    description: "",
    posterUrl: "",
    language: "",
    freeEpisodesCount: 3
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    await createSeries(form);
    alert("Series Created!");
    setForm({ title: "", description: "", posterUrl: "", language: "", freeEpisodesCount: 3 });
  };

  return (
    <Box sx={{ display: "flex" }}>
      <Sidebar />
      <Box sx={{ flexGrow: 1, p: 3 }}>
        <Typography variant="h4" gutterBottom>Create Series</Typography>
        <Paper sx={{ p: 3, maxWidth: 600 }}>
          <form onSubmit={handleSubmit}>
            <TextField fullWidth margin="normal" label="Title" value={form.title} onChange={(e) => setForm({...form, title: e.target.value})} />
            <TextField fullWidth margin="normal" label="Description" value={form.description} onChange={(e) => setForm({...form, description: e.target.value})} multiline rows={3} />
            <TextField fullWidth margin="normal" label="Poster URL" value={form.posterUrl} onChange={(e) => setForm({...form, posterUrl: e.target.value})} />
            <TextField fullWidth margin="normal" label="Language" value={form.language} onChange={(e) => setForm({...form, language: e.target.value})} />
            <TextField fullWidth margin="normal" label="Free Episodes Count" type="number" value={form.freeEpisodesCount} onChange={(e) => setForm({...form, freeEpisodesCount: e.target.value})} />
            <Button variant="contained" color="primary" type="submit" sx={{ mt: 2 }}>Create</Button>
          </form>
        </Paper>
      </Box>
    </Box>
  );
}

export default CreateSeries;
