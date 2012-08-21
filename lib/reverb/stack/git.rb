package :git do
  description 'Git Distributed Version Control'
  apt 'git'

  verify do
    has_apt "git"
  end
end
