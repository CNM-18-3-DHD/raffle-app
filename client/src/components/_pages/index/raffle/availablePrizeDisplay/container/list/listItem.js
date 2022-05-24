import { 
  ListItem,
  ListItemAvatar,
  ListItemText,
  Typography,
  Avatar
} from '@mui/material';

export default function DisplayListItem({row = {}}) {
  return (
    <ListItem alignItems='flex-start'>
      <ListItemAvatar>
        <Avatar 
          variant='rounded'
          src={row.image || 'https://via.placeholder.com/50x50?text=no+image'}
        />
      </ListItemAvatar>
      <ListItemText
        primary={`ID: ${row.id}`}
        secondary={
          <>
            <Typography
              sx={{ display: 'inline' }}
              component='span'
              variant='body2'
              color='text.primary'
            >
              {row.description || '(No description)'}
            </Typography>
          </>}
      />
    </ListItem>
  )
}