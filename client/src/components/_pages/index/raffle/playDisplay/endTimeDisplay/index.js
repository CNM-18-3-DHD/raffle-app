import { useState, useEffect, useContext } from 'react';
import { toast } from 'react-toastify';
import { Box, Typography, IconButton, Paper } from '@mui/material';
import RefreshIcon from '@mui/icons-material/Refresh';

import AppContext from '../../../../../_context';

export default function EndTimeDisplay() {
  const { raffle } = useContext(AppContext);
  const [data, setData] = useState(0);

  const loadData = async (contract) => {
    if (contract) {
      setData('(Loading)');
      contract.methods.endTime().call()
      .then((data) => {
        setData(data);
      })
      .catch((error) => {
        toast.error(error.message);
        setData('(Error loading)')
      });
    }
  }

  const datetime = new Date(data*1000);

  const handleRefresh = () => loadData(raffle);

  useEffect(() => {
    loadData(raffle);
  }, [raffle])

  return (
    <Paper variant='outlined'>
      <Box display='flex' py={1} px={2}>
        <Box sx={{ flexGrow: 1, display: 'flex', alignItems: 'center' }}>
          <Typography variant='body1'><b>End time:</b> {datetime.toLocaleString('en-GB')}</Typography>
        </Box>
        <IconButton size='small' onClick={handleRefresh}><RefreshIcon /></IconButton>
      </Box>
    </Paper>
  )
}