return (function(self, alpha)
  u(self).alpha = alpha < 0 and 0 or alpha > 1 and 1 or alpha
end)(...)
