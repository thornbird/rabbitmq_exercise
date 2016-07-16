#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

conn = Bunny.new
conn.start

ch   = conn.create_channel
q    = ch.queue("task_queue", durable: true)

ch.prefetch(1)
puts "[*] Waiting for messages in #{q.name}, To exist press CTRL+C"

begin
  q.subscribe(manual_ack: true, block: true) do |delivery_info, properties, body|
    puts " [x] Received #{body}"
    # imitate some work
    sleep body.count(".").to_i
    puts "[x] Done"
    #Notice, it's the channel's ack.
    ch.ack(delivery_info.delivery_tag)

    # cancel the consumer to exit
    # this code will let consumer stops soon after receiving one message
    #delivery_info.consumer.cancel
  end
rescue Interrupt
  conn.close
end
