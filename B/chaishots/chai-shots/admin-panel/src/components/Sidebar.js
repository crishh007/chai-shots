import React from 'react';
import { Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText, Toolbar, Box } from "@mui/material";
import { Link, useLocation, useNavigate } from "react-router-dom";
import VideoLibraryIcon from '@mui/icons-material/VideoLibrary';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import LogoutIcon from '@mui/icons-material/Logout';

function Sidebar() {
  const location = useLocation();
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem("token");
    navigate("/login");
  };

  // Only show sidebar if we are not on the login page
  if (location.pathname === "/login") {
    return null;
  }

  return (
    <Drawer 
      variant="permanent" 
      sx={{ 
        width: 240, 
        flexShrink: 0, 
        '& .MuiDrawer-paper': { width: 240, boxSizing: 'border-box' } 
      }}
    >
      <Toolbar /> {/* Adds padding so content isn't under AppBar */}
      <Box sx={{ overflow: 'auto' }}>
        <List>
          <ListItem disablePadding>
            <ListItemButton 
              component={Link} 
              to="/series"
              selected={location.pathname === "/series"}
            >
              <ListItemIcon>
                <VideoLibraryIcon color={location.pathname === "/series" ? "primary" : "inherit"} />
              </ListItemIcon>
              <ListItemText primary="Series" />
            </ListItemButton>
          </ListItem>

          <ListItem disablePadding>
            <ListItemButton 
              component={Link} 
              to="/upload"
              selected={location.pathname === "/upload"}
            >
              <ListItemIcon>
                <CloudUploadIcon color={location.pathname === "/upload" ? "primary" : "inherit"} />
              </ListItemIcon>
              <ListItemText primary="Upload Episode" />
            </ListItemButton>
          </ListItem>
        </List>
      </Box>

      {/* Push logout to the bottom */}
      <Box sx={{ flexGrow: 1 }} />
      <List>
        <ListItem disablePadding>
          <ListItemButton onClick={handleLogout}>
            <ListItemIcon>
              <LogoutIcon color="error" />
            </ListItemIcon>
            <ListItemText primary="Logout" sx={{ color: 'error.main' }} />
          </ListItemButton>
        </ListItem>
      </List>
    </Drawer>
  );
}

export default Sidebar;
