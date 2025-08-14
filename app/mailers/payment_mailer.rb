require "prawn/table"

class PaymentMailer < ApplicationMailer
  default from: "scribzfirst@gmail.com"

  def payment_receipt(user, order)
    @user  = user
    @order = order
    @date = Time.now
    transaction_id = SecureRandom.hex(6).upcase

    pdf = Prawn::Document.new(page_size: "A4", margin: 36) do |pdf|
      # ✅ Use Unicode font for ₹
     font_path = Rails.root.join("app/assets/fonts")
      pdf.font_families.update(
        "DejaVuSans" => {
          normal: font_path.join("DejaVuSans.ttf"),
          bold: font_path.join("DejaVuSans-Bold.ttf"),
          italic: font_path.join("DejaVuSans-Oblique.ttf"),
          bold_italic: font_path.join("DejaVuSans-BoldOblique.ttf")
        }
      )
      pdf.font "DejaVuSans"

      # -----------------
      # Header with Logo
      # -----------------
      logo_path = Rails.root.join("app/assets/images/Logo.png")
      if File.exist?(logo_path)
        pdf.image logo_path, width: 80, position: :left
      end
      
      
      pdf.stroke_horizontal_rule
      pdf.move_up 40
      pdf.move_down 60

      # -----------------
      # Receipt Title & Info
      # -----------------
      pdf.text "Payment Receipt", size: 18, style: :bold, color: "444444"
      pdf.move_down 8
      pdf.text "Order ##{@order.id}   |   Transaction: #{transaction_id}", size: 10, color: "666666"
      pdf.text "Date: #{@date.strftime('%B %d, %Y %H:%M')}", size: 10, color: "666666"
      pdf.move_down 20

      # -----------------
      # Customer Info Box
      # -----------------
      pdf.fill_color "F5F5F5"
      pdf.fill_rectangle [pdf.bounds.left, pdf.cursor], pdf.bounds.width, 30
      pdf.fill_color "000000"
      pdf.bounding_box([pdf.bounds.left + 10, pdf.cursor - 5], width: pdf.bounds.width - 20, height: 20) do
        pdf.text "Billed to: #{@user.email}", size: 11, style: :bold, valign: :center
      end
      pdf.move_down 20

      # -----------------
      # Items Table
      # -----------------
      data = [["Item", "Unit Price", "Qty", "Line Total"]]
      @order.order_items.each do |oi|
        name = oi.product&.name || "Item #{oi.product_id}"
        data << [
          name.truncate(60),
          format("₹%.2f", oi.price),
          oi.quantity.to_s,
          format("₹%.2f", (oi.price * oi.quantity))
        ]
      end

      total_amount = @order.order_items.sum { |i| i.price * i.quantity }
      data << [{ content: "", colspan: 2 }, "Total:", format("₹%.2f", total_amount)]

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "EEEEEE"
        columns(1..3).align = :right
        self.row_colors = ["F9F9F9", "FFFFFF"]
        self.header = true
        cells.padding = [8, 5, 8, 5]
        row(-1).font_style = :bold
      end

      pdf.move_down 20
      pdf.text "Thank you for your purchase!", size: 12, style: :bold, align: :center
      pdf.move_down 5
      pdf.text "If you have any questions, contact support@scribz.com", size: 9, align: :center, color: "666666"
    end

    attachments["receipt_order_#{order.id}.pdf"] = {
      mime_type: "application/pdf",
      content: pdf.render
    }

    mail(to: @user.email, subject: "Your Receipt for Order ##{order.id}")
  end
end
