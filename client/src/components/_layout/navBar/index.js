import { AppBar, Toolbar, Typography, Box } from '@mui/material';
import { Link } from 'react-router-dom';
import { styled } from '@mui/material/styles';
import RightActions from './rightActions';

const NavTitle = styled(Typography)(() => ({
  textDecoration: 'none',
  color: 'inherit',
}));

export default function LayoutNavBar() {
  return (
    <>
      <AppBar color='background' position='static'>
        <Toolbar>
          <NavTitle component={Link} to='/'>
            Raffle
          </NavTitle>
          <Box sx={{ flexGrow: 1 }} />
          <RightActions />
        </Toolbar>
      </AppBar>
    </>
  );
}
