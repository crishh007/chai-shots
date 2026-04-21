import React from "react";
import Sidebar from "../components/Sidebar";
import { Box, Typography } from "@mui/material";

function Dashboard() {
  return (
    <Box sx={{ display: "flex" }}>
      <Sidebar />
      <Box sx={{ flexGrow: 1, p: 3 }}>
        <Typography variant="h4" gutterBottom>Dashboard</Typography>
        <Typography variant="body1">Welcome to the Chai-Shots Admin Panel.</Typography>
      </Box>
    </Box>
  );
}

export default Dashboard;
