import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { Box, CssBaseline, ThemeProvider, createTheme, AppBar, Toolbar, Typography } from "@mui/material";

import Sidebar from "./components/Sidebar";
import PrivateRoute from "./components/PrivateRoute";
import Login from "./pages/Login";
import Series from "./pages/Series";
import UploadEpisode from "./pages/UploadEpisode";
import SeriesEpisodes from "./pages/SeriesEpisodes";

// Create a custom Yellow Theme
const theme = createTheme({
  palette: {
    primary: {
      main: '#FBC02D', // Strong yellow
      contrastText: '#000000',
    },
    secondary: {
      main: '#212121', // Dark grey/black for contrast
    },
    background: {
      default: '#f5f5f5',
    }
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <BrowserRouter>
        <Box sx={{ display: 'flex' }}>
          <CssBaseline />
          
          {/* Top AppBar */}
          <AppBar position="fixed" sx={{ zIndex: (theme) => theme.zIndex.drawer + 1 }}>
            <Toolbar>
              <Typography variant="h6" noWrap component="div" sx={{ fontWeight: 'bold' }}>
                Admin Control Panel
              </Typography>
            </Toolbar>
          </AppBar>

          <Sidebar />

          <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
            <Toolbar /> {/* Adds padding so content isn't under AppBar */}
            <Routes>
              <Route path="/" element={<Navigate to="/series" />} />
              <Route path="/login" element={<Login />} />

              <Route
                path="/series"
                element={
                  <PrivateRoute>
                    <Series />
                  </PrivateRoute>
                }
              />

              <Route
                path="/upload"
                element={
                  <PrivateRoute>
                    <UploadEpisode />
                  </PrivateRoute>
                }
              />

              <Route
                path="/series/:id/episodes"
                element={
                  <PrivateRoute>
                    <SeriesEpisodes />
                  </PrivateRoute>
                }
              />
            </Routes>
          </Box>
        </Box>
      </BrowserRouter>
    </ThemeProvider>
  );
}

export default App;
