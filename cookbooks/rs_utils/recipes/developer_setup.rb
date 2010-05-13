# Cookbook Name:: rs_utils
# Recipe:: developer_setup
#
# Copyright (c) 2009 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


bash "Setup bash shell" do
  code <<-EOH
    cat <<-EOF > ~/.bashrc
    alias pu=pushd
    alias po=popd
    alias rd='pushd +1'
    alias la='ls -aF'
    alias ll='ls -al'
    alias ls='ls -F'
    alias setd="D=`pwd`"
    alias che='chef-solo -c config/solo.rb -j config/solo.json'
    export GIT_SSH=~/gitssh
    alias rs_tail='tailf /var/log/messages | cut -b 57- | egrep -v "^RECV|^SEND| Checking for "'
    EOF
  EOH
end

package "vim"

bash "Setup vim config" do
  code <<-EOH
    cat << EOF > ~/.vimrc
    syntax on
    set autoindent
    set smartindent
    set shiftwidth=4
    set expandtab
    EOF
  EOH
end

