import React, { useEffect, useState } from "react";
import { getSeries, deleteSeries } from "../services/api";
import Sidebar from "../components/Sidebar";
import { Box, Typography, Card, CardContent, CardMedia, Button, Grid } from "@mui/material";
import { Link } from "react-router-dom";

function SeriesList() {
  const [series, setSeries] = useState([]);

  useEffect(() => {
    fetchSeries();
  }, []);

  const fetchSeries = async () => {
    const res = await getSeries();
    if (res.data.success) {
      setSeries(res.data.data);
    }
  };

  const handleDelete = async (id) => {
    await deleteSeries(id);
    fetchSeries();
  };

  return (
    <Box sx={{ display: "flex" }}>
      <Sidebar />
      <Box sx={{ flexGrow: 1, p: 3 }}>
        <Typography variant="h4" gutterBottom>All Series</Typography>
        <Grid container spacing={3}>
          {series.map((s) => (
            <Grid item xs={12} sm={6} md={4} key={s._id}>
              <Card>
                <CardMedia
                  component="img"
                  height="200"
                  image={s.posterUrl || "https://via.placeholder.com/200"}
                  alt={s.title}
                />
                <CardContent>
                  <Typography variant="h6">{s.title}</Typography>
                  <Typography variant="body2" color="text.secondary" gutterBottom>
                    {s.language} - {s.freeEpisodesCount} Free Episodes
                  </Typography>
                  <Button variant="contained" color="error" onClick={() => handleDelete(s._id)} sx={{ mr: 1 }}>
                    Delete
                  </Button>
                  <Button variant="outlined" component={Link} to={`/edit-series/${s._id}`}>
                    Edit
                  </Button>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Box>
    </Box>
  );
}

export default SeriesList;
